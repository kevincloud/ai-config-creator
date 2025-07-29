resource "aws_opensearchserverless_security_policy" "aoss_security_network_policy" {
  name        = "bedrock-knowledge-base-${var.unique_identifier}"
  type        = "network"
  description = "Network security policy for bedrock-knowledge-base-${var.unique_identifier}"
  policy = jsonencode([
    {
      Description = "Public access to collection and Dashboards endpoint for example collection",
      Rules = [
        {
          Resource = [
            "collection/bedrock-knowledge-base-${var.unique_identifier}"
          ],
          ResourceType = "collection"
        },
        {
          Resource = [
            "collection/bedrock-knowledge-base-${var.unique_identifier}"
          ],
          ResourceType = "dashboard"
        }
      ],
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "aoss_security_enc_policy" {
  name        = "bedrock-knowledge-base-${var.unique_identifier}"
  type        = "encryption"
  description = "Encryption security policy for bedrock-knowledge-base-${var.unique_identifier}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/bedrock-knowledge-base-${var.unique_identifier}"
        ],
        ResourceType = "collection",
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_access_policy" "aoss_security_data_policy" {
  name        = "bedrock-knowledge-base-${var.unique_identifier}"
  type        = "data"
  description = "read and write permissions"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/bedrock-knowledge-base-${var.unique_identifier}"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/bedrock-knowledge-base-${var.unique_identifier}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

resource "aws_opensearchserverless_collection" "aoss_collection" {
  name = "bedrock-knowledge-base-${var.unique_identifier}"
  type = "VECTORSEARCH"
  depends_on = [
    aws_opensearchserverless_security_policy.aoss_security_network_policy,
    aws_opensearchserverless_security_policy.aoss_security_enc_policy,
    aws_opensearchserverless_access_policy.aoss_security_data_policy
  ]
}

resource "aws_bedrockagent_knowledge_base" "togglebank-docs-and-cl" {
  name     = "${var.unique_identifier}-togglebank-docs-and-cl"
  role_arn = aws_iam_role.chat-app-bedrock-role.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = 1024
          embedding_data_type = "FLOAT32"
        }
      }

      supplemental_data_storage_configuration {
        storage_location {
          type = "S3"
          s3_location {
            uri = "s3://${aws_s3_bucket.bucket_rag_customerlist.bucket}"
          }
        }
        storage_location {
          type = "S3"
          s3_location {
            uri = "s3://${aws_s3_bucket.bucket_rag_faq.bucket}"
          }
        }
      }
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.aoss_collection.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
}

resource "aws_iam_role" "chat-app-bedrock-role" {
  name               = "${var.unique_identifier}-chat-app-bedrock-role"
  assume_role_policy = data.aws_iam_policy_document.assume-bedrock-role-doc.json

  tags = {
    Name  = "${var.unique_identifier}-vault-ec2-allow-iam-role"
    owner = var.owner
  }
}

data "aws_iam_policy_document" "assume-bedrock-role-doc" {
  version = "2012-10-17"
  statement {
    sid    = "AmazonBedrockKnowledgeBaseTrustPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
    }
  }
}

resource "aws_iam_policy" "chat_policy_1" {
  name   = "AmazonBedrockFoundationModelPolicyForKnowledgeBase_${var.unique_identifier}"
  policy = data.aws_iam_policy_document.chat_app_policy_1.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_1" {
  role       = aws_iam_role.chat-app-bedrock-role.name
  policy_arn = aws_iam_policy.chat_policy_1.arn
}

data "aws_iam_policy_document" "chat_app_policy_1" {
  version = "2012-10-17"
  statement {
    sid       = "BedrockInvokeModelStatement"
    effect    = "Allow"
    resources = ["arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"]

    actions = [
      "bedrock:InvokeModel"
    ]
  }
}

resource "aws_iam_policy" "chat_policy_2" {
  name   = "AmazonBedrockOSSPolicyForKnowledgeBase_${var.unique_identifier}"
  policy = data.aws_iam_policy_document.chat_app_policy_2.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_2" {
  role       = aws_iam_role.chat-app-bedrock-role.name
  policy_arn = aws_iam_policy.chat_policy_2.arn
}

data "aws_iam_policy_document" "chat_app_policy_2" {
  version = "2012-10-17"
  statement {
    sid       = "OpenSearchServerlessAPIAccessAllStatement"
    effect    = "Allow"
    resources = [aws_bedrockagent_knowledge_base.togglebank-docs-and-cl.arn] # Replace with actual OpenSearch Serverless ARN
    actions   = ["aoss:APIAccessAll"]
  }
}

resource "aws_iam_policy" "chat_policy_3" {
  name   = "AmazonBedrockS3PolicyForKnowledgeBase_${var.unique_identifier}"
  policy = data.aws_iam_policy_document.chat_app_policy_3.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_3" {
  role       = aws_iam_role.chat-app-bedrock-role.name
  policy_arn = aws_iam_policy.chat_policy_3.arn
}

data "aws_iam_policy_document" "chat_app_policy_3" {
  version = "2012-10-17"
  statement {
    sid       = "S3ListBucketStatement"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.bucket_rag_customerlist.arn, aws_s3_bucket.bucket_rag_faq.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

