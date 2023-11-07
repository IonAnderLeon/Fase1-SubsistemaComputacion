
$domain="dc=marenostrum,dc=mylocal"

$gruposCsv=Read-Host "Introduce el fichero csv de Grupos:"

$fichero = import-csv -Path $gruposCsv -delimiter *
foreach($linea in $fichero)
{
	
	New-ADGroup -Name:$linea.Name -Description:$linea.Description `
		-GroupCategory:$linea.Category `
		-GroupScope:$linea.Scope  `
		-Path:$linea.Path
}
write-Host ""
write-Host "Se han creado los grupos en el dominio $domain" -Fore green
write-Host "" 
