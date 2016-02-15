defmodule Lista do
  def len([]), do: 0
  def len([_head|tail]), do: 1 + len(tail)
end

defmodule Git do
  def push([]), do: []
  def push([ actual | resto ]) do
    IO.puts "Ejecutando en #{actual}"
    {remote_url, _} = get_remote_url(actual)

    [_, _, namespace, repo] = Path.split(remote_url)

    args_url =  user_password_url("salvarez", "1goshushijo6", namespace, repo)
                |> String.rstrip

    args_user_password = ["push", "--repo", args_url]

    cmd("git", args_user_password, actual)
    push(resto)
  end

  def status([]), do: []
  def status([ actual | resto ]) do
    IO.puts "Ejecutando status en #{actual}"
    
    case cmd("git", ["status"], actual) do
      {"On branch master\nnothing to commit, working directory clean\n", _} -> status(resto)
      {output, _} ->  IO.puts output
                      raise "Hay cambios para commitear en #{actual}"

    end
  end

  def log([]), do: []
  def log([], _), do: []
  def log([ actual | resto ]) do
    IO.puts "Ultimo commit en: #{actual}"

    {output, _} = cmd("git", ["log", "--pretty=oneline", "--abbrev-commit", "-1"], actual)
    [_, msg] = String.split(output, " ", parts: 2)

    IO.puts msg

    log(resto)
  end
  def log([ actual | resto ], m) do
    IO.puts "Ultimo commit en: #{actual}"

    {output, _} = cmd("git", ["log", "--pretty=oneline", "--abbrev-commit", "-1"], actual)
    [_, msg] = String.split(output, " ", parts: 2)

    cond do
      msg != m -> raise "No es \"#{m}\""
      msg == m -> log(resto, m)
    end

  end

  def add([]), do: []
  def add([ actual | resto ]) do
    IO.puts "Agregando todos los archivos en: #{actual}"
    {output, _} = cmd("git", ["add", "."], actual)

    IO.puts output

    [ actual | add(resto) ]

  end

  def commit([], _), do: []
  def commit([ actual | resto ], m) do
    IO.puts "Commiteando archivos en: #{actual}"
    {output, _} = cmd("git", ["commit", "-m", "#{m}"], actual)

    [ actual | commit(resto, m) ]

  end



  def user_password_url(user, password, namespace, repo) do
    Enum.join(["https://", user, ":", password, "@", "gitlab.educ.ar", "/", namespace, "/", repo])
  end

  def get_remote_url(dir) do
    cmd("git", ["config", "--get", "remote.origin.url"], dir)
  end

  defp cmd(cmd, args, dir), do: System.cmd(cmd, args, cd: dir)

end

defmodule Funciones do

  def filtrar_directorios([]), do: []
  def filtrar_directorios([ actual | resto ]) do
    case File.dir? actual do
      true -> [ actual | filtrar_directorios resto ]
      _ -> filtrar_directorios resto
    end

  end

  def encontrar_git_root([]), do: []
  def encontrar_git_root([ actual | resto ]) do
    {_, f} = File.ls actual

    paths_correcto = armar_path actual, f
    dirs = filtrar_directorios paths_correcto

    case Lista.len(dirs) do
      1 ->  [ hd(dirs) | encontrar_git_root resto ]
      0 ->  raise "ERROR: No hay subdirectorio en #{actual}"
      _ ->  raise "ERROR: El directorio #{actual} posee mas de una carpeta interna"
            encontrar_git_root resto
    end

  end

  def hacer_magia([], _, _), do: []
  def hacer_magia([ actual | resto ], cmd, args) do
    IO.puts "Ejecutando en #{actual}"
    case System.cmd(cmd, args, cd: actual) do
      {output, 0} ->  IO.puts "Comando ejecutado correctamente en #{actual}"
                      IO.puts output
      {_, _} -> IO.puts "Comando ejecutado erroneamente en #{actual}"
    end

    [ actual | hacer_magia(resto, cmd, args) ]
  end

  def pushes(directorios), do: Git.push(directorios)
  def statuses(directorios), do: Git.status(directorios)
  def logses(directorios, m), do: Git.log(directorios, m)
  def logses(directorios), do: Git.log(directorios)
  def addses(directorios), do: Git.add(directorios)
  def commitses(directorios, m), do: Git.commit(directorios, m)

  def armar_path(_pre, []), do: []
  def armar_path(pre, [ actual | resto ]) do
    [ Enum.join([pre, "/", actual]) | armar_path(pre, resto) ]
  end


end

dir = "../educar-debs"
{_, lista} = File.ls dir

Funciones.armar_path(dir, lista)
|> Funciones.filtrar_directorios
|> Funciones.encontrar_git_root
#|> Funciones.addses
#|> Funciones.commitses("Se agrega README vacio")
#|> Funciones.pushes
#|> Funciones.statuses
#|> Funciones.logses("Se agrega README vacio\n")
|> Funciones.logses


