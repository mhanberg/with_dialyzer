# WithDialyzer

Demo of a dialyzer warning that I believe is caused by a new way of compiling the `with` special form into Erlang

Using the versions

```
erlang = "26.2.2"
elixir = "ref:52eaf1456182d5d6cce22a4f5c3f6ec9f4dcbfd9"
```

This case I believe is somewhat interesting because according to the erlang docs, the `:inet.gethostname/0` function "never fails".

```elixir
with {:ok, host} <- :inet.gethostname() do
  host
end
```

```
lib/with_dialyzer.ex:3:pattern_match_cov
The pattern
variable_

can never match, because previous clauses completely cover the type
{:ok, [byte()]}.
```

However, if you switch this from the left stab operator to the match operator, it passes

```elixir
with {:ok, host} = :inet.gethostname() do
  host
end
```

This case was reduced from the application code

```elixir
with {:ok, host} <- :inet.gethostname(),
     node = :"#{sname}@#{host}",
     true <- connect(node, port, 120) do
  NextLS.Logger.info(logger, "Connected to node #{node}")

  :next_ls
  |> :code.priv_dir()
  |> Path.join("monkey/_next_ls_private_compiler.ex")
  |> then(&:rpc.call(node, Code, :compile_file, [&1]))
  |> tap(fn
    {:badrpc, error} ->
      NextLS.Logger.error(logger, "Bad RPC call to node #{node}: #{inspect(error)}")
      send(me, {:cancel, error})

    _ ->
      :ok
  end)

  send(me, {:node, node})
else
  error ->
    send(me, {:cancel, error})
end
```
