return {
  {
    "3rd/diagram.nvim",
    dependencies = {
      "3rd/image.nvim",
    },
    opts = function()
      return {
        integrations = {
          require("diagram.integrations.markdown"),
        },
      }
    end,
    keys = {
      {
        "<leader>md",
        function()
          local ok, diagram = pcall(require, "diagram")
          if ok and type(diagram.show_diagram_hover) == "function" then
            diagram.show_diagram_hover()
          end
        end,
        ft = "markdown",
        desc = "Show Markdown diagram",
      },
    },
  },
}
