defmodule Mix.Tasks.Assets.Copy do
  use Mix.Task

  @shortdoc "Copies static asset runtime files"

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Copying static asset runtime files")

    copy_dir!("assets/semantic/dist", "priv/static/dist")
    copy_dir!("assets/node_modules/hugerte", "priv/static/vendor/hugerte")

    copy_file!(
      "assets/node_modules/codemirror/lib/codemirror.css",
      "priv/static/vendor/codemirror/codemirror.css"
    )

    copy_file!("assets/images/page_loading.gif", "priv/static/images/page_loading.gif")
  end

  defp copy_dir!(source, target) do
    File.rm_rf!(target)
    File.mkdir_p!(Path.dirname(target))
    File.cp_r!(source, target)
  end

  defp copy_file!(source, target) do
    File.mkdir_p!(Path.dirname(target))
    File.cp!(source, target)
  end
end
