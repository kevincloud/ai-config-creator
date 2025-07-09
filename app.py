import json
import time
import os
from dotenv import load_dotenv

# import prompts
from AIConfigs import AIConfigs

load_dotenv()

LD_API_KEY = os.getenv("LD_API_KEY") or None
LD_PROJECT_KEY = os.getenv("LD_PROJECT_KEY") or None

if not LD_API_KEY or not LD_PROJECT_KEY:
    print("Please set the LD_API_KEY and LD_PROJECT_KEY environment variables.")
    print("You can create a .env file with the following content:")
    print("LD_API_KEY=your-api-key")
    print("LD_PROJECT_KEY=your-project-key")
    print("Or set them directly in your environment.")
    exit(1)

CONFIGS_FILE = "configs.json"
PROMPTS_RAG_FILE = "prompts-rag.json"
PROMPTS_JUDGE_FILE = "prompts-judge.json"

ai_configs = AIConfigs(LD_PROJECT_KEY, LD_API_KEY)


def main():
    # Create AI Config Models
    create_custom_models(CONFIGS_FILE)

    # Create AI Configs
    create_ai_configs()

    # Create AI Config Variations
    create_variations(PROMPTS_RAG_FILE)
    create_variations(PROMPTS_JUDGE_FILE)

    print("AI Configs and Models created successfully.")


# Create AI Config Models
def create_custom_models(filename):
    try:
        with open(filename, "r") as config_file:
            data = json.load(config_file)
            for config in data["configs"]:
                response = ai_configs.create_ai_config_model(
                    config["name"],
                    config["key"],
                    config["id"],
                    icon=config.get("icon") or None,
                    provider=config.get("provider") or None,
                    params=config.get("params") or None,
                    custom_params=config.get("customParams") or None,
                    cost_per_input_token=config.get("costPerInputToken") or None,
                    cost_per_output_token=config.get("costPerOutputToken") or None,
                )
                data = json.loads(response)
                if "message" in data:
                    print(
                        f"Custom model \"{config['name']}\" already exists. Skipping creation."
                    )
                else:
                    print(f"Custom model \"{config['name']}\" created successfully.")
    except FileNotFoundError:
        print(f"Error: '{CONFIGS_FILE}' not found.")
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON format in '{CONFIGS_FILE}'.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


# Create AI Configs
def create_ai_configs():
    # Create ToggleBank RAG AI Config
    response = ai_configs.create_ai_config("ToggleBank RAG", "toggle-bank-rag")
    data = json.loads(response)
    if "message" in data:
        print("ToggleBank RAG AI Config already exists. Skipping creation.")
    else:
        print("ToggleBank RAG AI Config created successfully.")
    # Create LLM-as-Judge AI Config
    response = ai_configs.create_ai_config("LLM-as-Judge", "llm-as-judge")
    data = json.loads(response)
    if "message" in data:
        print("LLM-as-Judge AI Config already exists. Skipping creation.")
    else:
        print("LLM-as-Judge AI Config created successfully.")


# Create AI Config Variations
def create_variations(filename):
    try:
        with open(filename, "r") as prompts_file:
            data = json.load(prompts_file)
            for prompt in data["prompts"]:
                response = ai_configs.create_ai_config_variation(
                    "toggle-bank-rag",
                    prompt["key"],
                    prompt["name"],
                    model=prompt["model"],
                    model_config_key=prompt["model_key"],
                    prompt=prompt["prompt"],
                    custom_params=(
                        prompt["custom_params"] if "custom_params" in prompt else None
                    ),
                )
                data = json.loads(response)
                if "message" in data:
                    print(
                        f"Variation \"{prompt['name']}\" already exists. Skipping creation."
                    )
                else:
                    print(f"Variation \"{prompt['name']}\" created successfully.")
    except FileNotFoundError:
        print(f"Error: '{filename}' not found.")
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON format in '{filename}'.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    main()
