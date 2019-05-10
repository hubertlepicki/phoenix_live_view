ExUnit.start()

defmodule Phoenix.LiveView.ChannelTest do
  use ExUnit.Case

  @doc false
  def find_file(params, ref, nil) do
    {_, results} = find_file(params, ref, {[], []})
    Enum.reverse(results)
  end

  def find_file(%{"__PHX_FILE__" => _ref}, _ref, {path, _}), do: {:ok, Enum.reverse(path)}
  def find_file(params, _ref, _path) when not is_map(params), do: nil

  def find_file(params, _ref, {path, acc}) do
    Enum.reduce(params, {path, acc}, fn {key, sub_params}, {path_acc, found_acc} ->
      next_path = [key | path_acc]
      case find_file(sub_params, _ref, {next_path, found_acc}) do
        {:ok, path} -> {path_acc, [path | found_acc]}
        nil -> {path_acc, found_acc}
        other -> other
      end
    end)
  end

  describe "find_file/3" do
    test "returns the path of the nested file" do
      params = %{
        "user" => %{
          "avatar" => %{
            "__PHX_FILE__" => "some_ref"
          },
          "other" => %{
            "__PHX_FILE__" => "some_other_ref"
          },
          "not_file" => "nil"
        }
      }

      assert find_file(params, "todo", nil) == [["user", "avatar"], ["user", "other"]]
    end
  end
end
