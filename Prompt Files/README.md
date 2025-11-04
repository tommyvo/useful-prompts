# Prompt Files

This folder contains prompt files.

To use prompt files in Github Copilot in VSCode, see [here](https://code.visualstudio.com/docs/copilot/customization/prompt-files).

**Note:** When naming the prompt file, use dash-case.

To use this prompt file with Opencode, see [here](https://opencode.ai/docs/commands/). You may need to update the header portion of each markdown file for Opencode (things like `mode` won't be available in Opencode, and would need to change to build attribute).

In the original file, if we have an attribute of `mode: agent`, it's the same as `agent: build` on Opencode side. If the markdown has an attribute of `mode: ask`, it's the same as `agent: plan` on Opencode (for the default agent modes).
