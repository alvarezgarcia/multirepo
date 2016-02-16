defmodule Lista do
  def len([]), do: 0
  def len([_head|tail]), do: 1 + len(tail)
end

defmodule Git do

  def status([]), do: []
  def status([ actual | resto ]) do
    IO.puts "\ngit status en #{actual}"
    
    case cmd("git", ["status"], actual) do
      {"On branch master\nnothing to commit, working directory clean\n", _} ->  IO.puts "OK"
                                                                                status(resto)
      {output, _} ->  IO.puts output
                      raise "Hay cambios para commitear en #{actual}"

    end
  end

  def log([], _), do: []
  def log([ actual | resto ], count) do
    IO.puts "Ultimo commit en: #{actual}"

    {output, _} = cmd("git", ["log", "--pretty=oneline", "--abbrev-commit", count], actual)
    [_, msg] = String.split(output, " ", parts: 2)

    IO.puts msg

    log(resto, count)
  end

  def log_compare([], _), do: []
  def log_compare([ actual | resto ], m) do
    IO.puts "Ultimo commit en: #{actual}"

    {output, _} = cmd("git", ["log", "--pretty=oneline", "--abbrev-commit", "-1"], actual)
    [_, msg] = String.split(output, " ", parts: 2)

    cond do
      msg != m -> raise "No es \"#{m}\""
      msg == m -> log_compare(resto, m)
    end

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

  def statuses(directorios), do: Git.status(directorios)
  def logses(directorios), do: Git.log(directorios, -1)
  def logses_compare(directorios, m), do: Git.log_compare(directorios, m)

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
|> Funciones.statuses
#|> Funciones.logses_compare("Se agrega README vacio\n")
#|> Funciones.logses


