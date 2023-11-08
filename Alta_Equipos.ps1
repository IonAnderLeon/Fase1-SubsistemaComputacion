#Computer:Path
#W10-CLI001:OU=Equipos-DepInf,OU=Dep-Informatica
#W10-CLI002:OU=Equipos-DepInf,OU=Dep-Informatica

#OU=Equipos-DepInf,OU=Dep-Informatica,DC=smr,DC=local


$domain="dc=marenostrum,dc=mylocal"


#Creación de los grupos a partir de un fichero csv

#Lee el fichero grupos.csv. El carácter delimitador de columna es :
$equiposCsv=Read-Host "Introduce el fichero csv de Equipos:"
$fichero= import-csv -Path $equiposCsv -delimiter "*"

foreach($line in $fichero)
{
	New-ADComputer -Enabled:$true -Name:$line.Computer -Path:$line.Path -SamAccountName:$line.Computer
}

write-Host ""
write-Host "Se han creado los equipos en el dominio $domain" -Fore green
write-Host "" 