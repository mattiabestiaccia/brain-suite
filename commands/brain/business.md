# /brain:business

Explore the **business** dimension. This is a shortcut for `/brain:explore business`.

## Execution

1. Resolve the explore command path:
   ```bash
   EXPLORE_CMD=$(echo $HOME/.claude/commands/brain/explore.md)
   ```

2. Read the explore command file:
   Read `$EXPLORE_CMD` for the complete exploration instructions.

3. Execute ALL instructions from the explore command with dimension set to **business**.

The dimension is `business`. Do NOT ask the user which dimension to explore --
it is already determined. Proceed directly with the exploration flow.
