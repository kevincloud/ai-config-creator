import json
from RestAdapter import RestAdapter


class AIConfigs:
    http_request = None
    api_key = ""

    def __init__(self, project_key, api_key):
        self.project_key = project_key
        self.api_key = api_key
        self.http_request = RestAdapter("app.launchdarkly.com", "v2", self.api_key)

    def create_ai_config_model(
        self,
        model_name,
        model_key,
        model_id,
        icon=None,
        provider=None,
        params=None,
        custom_params=None,
        cost_per_input_token=None,
        cost_per_output_token=None,
    ):
        payload = {
            "key": model_key,
            "name": model_name,
            "id": model_id,
        }
        if icon:
            payload["icon"] = icon
        if provider:
            payload["provider"] = provider
        if params:
            payload["params"] = params
        if custom_params:
            payload["customParams"] = custom_params
        if cost_per_input_token:
            payload["costPerInputToken"] = cost_per_input_token
        if cost_per_output_token:
            payload["costPerOutputToken"] = cost_per_output_token

        response = self.http_request.post(
            f"/projects/{self.project_key}/ai-configs/model-configs",
            json=payload,
            beta=True,
        )

        if response.status_code == 201:
            return response.text
        else:
            return response.text

    def create_ai_config(self, config_name, config_key, description=None):
        payload = {
            "key": config_key,
            "name": config_name,
        }
        if description:
            payload["description"] = description

        response = self.http_request.post(
            f"/projects/{self.project_key}/ai-configs", json=payload, beta=True
        )

        if response.status_code == 201:
            return response.text
        else:
            return response.text

    def create_ai_config_variation(
        self,
        config_key,
        key,
        name,
        comment=None,
        model=None,
        model_config_key=None,
        prompt=None,
        custom_params=None,
    ):
        payload = {
            "key": key,
            "name": name,
            "modelConfigKey": model_config_key,
            "model": {"modelName": model},
            "messages": [{"content": prompt, "role": "system"}],
        }
        if comment:
            payload["comment"] = comment
        if custom_params:
            payload["model"]["custom"] = custom_params

        response = self.http_request.post(
            f"/projects/{self.project_key}/ai-configs/{config_key}/variations",
            json=payload,
            beta=True,
        )

        return response.text

    def get_ai_config_model(self, model_key):
        response = self.http_request.get(
            f"/projects/{self.project_key}/ai-configs/model-configs/{model_key}",
            beta=True,
        )

        if response.status_code == 200:
            return response.text
        else:
            return response.text

    def get_ai_config(self, config_key):
        response = self.http_request.get(
            f"/projects/{self.project_key}/ai-configs/{config_key}", beta=True
        )

        if response.status_code == 200:
            return response.text
        else:
            return response.text

    def get_ai_config_variation(self, config_key, variation_key):
        response = self.http_request.get(
            f"/projects/{self.project_key}/ai-configs/{config_key}/variations/{variation_key}",
            beta=True,
        )

        if response.status_code == 200:
            return response.text
        else:
            return response.text
