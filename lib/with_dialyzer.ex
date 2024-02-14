defmodule WithDialyzer do
  def hello do
    with {:ok, host} <- :inet.gethostname() do
      host
    end
  end
end
