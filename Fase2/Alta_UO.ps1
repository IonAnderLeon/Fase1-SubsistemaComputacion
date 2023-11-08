

$domain="dc=marenostrum,dc=mylocal"


$ficheroCsvUO=Read-Host "Introduce el fichero csv de UO's:"


$fichero = import-csv -Path $ficheroCsvUO -delimiter :

foreach($line in $fichero)
{

	
        	New-ADOrganizationalUnit  -Description:$line.Description -Name:$line.Name -Path:$line.Path-ProtectedFromAccidentalDeletion:$true
        
	
}
Write-Host "Se han creado las UOs satisfactoriamente en el dominio $domain"
