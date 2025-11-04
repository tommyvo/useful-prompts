# Custom Chat Modes

This folder contains definitions for custom chat modes. To use this in Github Copilot in VSCode, see [here](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes).

To use custom chat modes in Opencode, see [here](https://opencode.ai/docs/agents/). You may need to update the header portion of each markdown file for Opencode (things like `mode` won't be available in Opencode, and would need to change to build attribute).

In the original file, if we have an attribute of `mode: agent`, it's the same as `agent: build` on Opencode side. If the markdown has an attribute of `mode: ask`, it's the same as `agent: plan` on Opencode (for the default agent modes).
