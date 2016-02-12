defmodule Lista do
  def len([]), do: 0
  def len([_head|tail]), do: 1 + len(tail)
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
      _ ->  IO.puts "ERROR: El directorio #{actual} posee mas de una carpeta interna"
            encontrar_git_root resto
    end

  end

  def hacer_magia([], _, _), do: []
  def hacer_magia([ actual | resto ], cmd, args) do
    IO.puts "Ejecutando en #{actual}"
    case System.cmd(cmd, args, cd: actual) do
      {_output, 0} -> IO.puts "Comando ejecutado correctamente en #{actual}"
                      IO.puts _output
      {_, _} -> IO.puts "Comando ejecutado erroneamente en #{actual}"
    end
    #hacer_magia resto, cmd, args

    [ actual | hacer_magia(resto, cmd, args) ]
  end

  defp armar_path(_pre, []), do: []
  defp armar_path(pre, [ actual | resto ]) do
    [ Enum.join([pre, "/", actual]) | armar_path(pre, resto) ]
  end

end

{_, lista} = File.ls "."
#lista = ["/tmp/", "/etc/issue", "/etc/hosts"]

#args = ["-i", "s/Sebastian Alvarez/Equipo de Desarrollo/g;s/salvarez/desarrollo/g", "debian/changelog", "debian/control"]

Funciones.filtrar_directorios(lista)
|> Funciones.encontrar_git_root
|> Funciones.hacer_magia("pdebuild", [])
#|> Funciones.hacer_magia("git", ["status"])
#|> Funciones.hacer_magia("git", ["add", "."])
#|> Funciones.hacer_magia("git", ["commit", "-m", "Se cambian mantainers"])
#|> Funciones.hacer_magia("git", ["push", "origin", "master"])
