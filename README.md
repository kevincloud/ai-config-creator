#  LD AI Config creator

This script creates the LaunchDarkly resources required for Marek Poliks' [HallucinationTracker](https://github.com/mpoliks/HallucinationTracker).

### Prerequisites

* **LaunchDarkly API token**:
  * Admin role
  * Service token

### Running the Script

1. Rename the `example.env` file to `.env`
2. Replace the `LD_API_KEY` placeholder value with your LaunchDarkly API key
3. Replace the `LD_PROJECT_KEY` placeholder value with your project key
4. Run `app.py`:

```
python app.py
```
