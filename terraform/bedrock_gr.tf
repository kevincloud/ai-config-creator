resource "aws_bedrock_guardrail" "hallucination_guardrail" {
  name                      = "${var.unique_identifier}-HallucinationBot"
  blocked_input_messaging   = "I'm unable to answer this question for you, let me route to you a live agent ASAP!"
  blocked_outputs_messaging = "I'm unable to answer this question for you, let me route to you a live agent ASAP!"
  description               = "HallucinationBot is designed to assist users while adhering to strict content policies."

  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "SEXUAL"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "HATE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "VIOLENCE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "INSULTS"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "MISCONDUCT"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "NONE"
      type            = "PROMPT_ATTACK"
    }
  }

  sensitive_information_policy_config {
    pii_entities_config {
      action = "BLOCK"
      type   = "US_SOCIAL_SECURITY_NUMBER"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "PHONE"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "EMAIL"
    }
    pii_entities_config {
      action = "BLOCK"
      type   = "AGE"
    }
  }

  contextual_grounding_policy_config {
    filters_config {
      type      = "GROUNDING"
      threshold = 0.6
    }
    filters_config {
      type      = "RELEVANCE"
      threshold = 0.6
    }
  }

  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
  }
}

resource "aws_bedrock_guardrail_version" "hallucination_guardrail_version" {
  guardrail_arn = aws_bedrock_guardrail.hallucination_guardrail.guardrail_arn
  skip_destroy  = true
}

resource "aws_bedrock_guardrail" "content_guardrail" {
  name                      = "${var.unique_identifier}-ContentBot"
  blocked_input_messaging   = "Sorry, the model cannot answer this question."
  blocked_outputs_messaging = "Sorry, the model cannot answer this question."
  description               = "ContentBot is designed to assist users while adhering to strict content policies."

  content_policy_config {
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "SEXUAL"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "HATE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "VIOLENCE"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "INSULTS"
    }
    filters_config {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "MISCONDUCT"
    }
  }

  contextual_grounding_policy_config {
    filters_config {
      type      = "RELEVANCE"
      threshold = 0.6
    }
  }

  word_policy_config {
    managed_word_lists_config {
      type = "PROFANITY"
    }
  }
}

resource "aws_bedrock_guardrail_version" "content_guardrail_version" {
  guardrail_arn = aws_bedrock_guardrail.content_guardrail.guardrail_arn
  skip_destroy  = true
}

