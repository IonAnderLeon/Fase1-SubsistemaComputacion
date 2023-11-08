#Variables globales
$domain="dc=smr,dc=local"
#
#Funciones en la cabecera del script
#

function Show-Menu
{
     param (
           [string]$Titulo = 'Menú principal'
     )
     Clear-Host
     Write-Host "================ $Titulo ================"
    
     Write-Host "1: Opción '1' Crear UOs."
     Write-Host "2: Opción '2' Crear Grupos."
     Write-Host "3: Opción '3' Crear Usuarios."
     Write-Host "4: Opción '4' Crear Equipos."
     Write-Host "Q: Opción 'Q' Salir."
}
function alta_UOs
{
     $ficheroCsvUO=Read-Host "Introduce el fichero csv de UO's:"
     $ficheroImportado = import-csv -Path $ficheroCsvUO -delimiter *
     foreach($line in $ficheroImportado)
     {
          New-ADOrganizationalUnit -Description:$line.Description -Name:$line.Name `
		-Path:$line.Path -ProtectedFromAccidentalDeletion:$true 
     }
     Write-Host "Se han creado las UOs satisfactoriamente en el dominio $domain"
}
function alta_grupos
{
     	$gruposCsv=Read-Host "Introduce el fichero csv de Grupos:"
	$ficheroImportado = import-csv -Path $gruposCsv -delimiter *
	foreach($linea in $ficheroImportado)
	{
		
		New-ADGroup -Name:$linea.Name -Description:$linea.Description `
			-GroupCategory:$linea.Category `
			-GroupScope:$linea.Scope  `
			-Path:$linea.Path
	}
 	 Write-Host "Se han creado las grupos satisfactoriamente en el dominio $domain"
     
}
function alta_usuarios
{
	$fileUsersCsv=Read-Host "Introduce el fichero csv de los usuarios:"



$fichero = import-csv -Path $fileUsersCsv -Delimiter "*"
						     		     
foreach($linea in $fichero)
{
	
	$passAccount=ConvertTo-SecureString $linea.Password -AsPlainText -force
	$Surnames=$linea.FirstName+' '+$linea.LastName
	$nameLarge=$linea.Name+' '+$linea.FirstName+' '+$linea.LastName
	$email=$linea.Email
	[boolean]$Habilitado=$true
    	If($linea.Enabled -Match 'false') { $Habilitado=$false}
	#Establecer los días de expiración de la cuenta (Columna del csv ExpirationAccount)
   	$ExpirationAccount = $linea.ExpirationAccount
    	$timeExp = (get-date).AddDays($ExpirationAccount)
	
	New-ADUser -SamAccountName $linea.Account -UserPrincipalName $linea.Account -Name $linea.Account `
		-Surname $Surnames -DisplayName $nameLarge -GivenName $linea.Name `
		-Description "Cuenta de $nameLarge" -EmailAddress $email `
		-AccountPassword $passAccount -Enabled $Habilitado `
		-CannotChangePassword $false -ChangePasswordAtLogon $true `
		-PasswordNotRequired $false -Path $linea.Path -AccountExpirationDate $timeExp
  		
		
  
  	## Establecer horario de inicio de sesión       
        $horassesion = $linea.NetTime -replace(" ","")
        net user $linea.Account /times:$horassesion 
	
	#Asignar cuenta de Usuario a Grupo
	# Distingued Name CN=Nombre-grupo,ou=..,ou=..,dc=..,dc=...
	$cnGrpAccount="Cn="+$linea.Group+","+$linea.Path
	Add-ADGroupMember -Identity $cnGrpAccount -Members $linea.Account
		
	}     
}
function alta_equipos
{
	


$equiposCsv=Read-Host "Introduce el fichero csv de Equipos:"
$fichero= import-csv -Path $equiposCsv -delimiter "*"

foreach($line in $fichero)
{
	New-ADComputer -Enabled:$true -Name:$line.Computer -Path:$line.Path -SamAccountName:$line.Computer
}

write-Host ""
write-Host "Se han creado los equipos en el dominio $domain" -Fore green
write-Host "" 
		
	
}

#Primero comprobaremos si se tiene cargado el módulo Active Directory
if (!(Get-Module -Name ActiveDirectory)) #Accederá al then solo si no existe una entrada llamada ActiveDirectory
{
  Import-Module ActiveDirectory #Se carga el módulo
}


#
#MENU PRINCIPAL
#
do
{
     Show-Menu
     $input = Read-Host "Por favor, pulse una opción"
     switch ($input)
     {
           '1' {
                Clear-Host
                alta_UOs
           } '2' {
                Clear-Host
                alta_grupos
           } '3' {
                Clear-Host
                alta_usuarios
           } '4' {
                Clear-Host
                alta_equipos
           } 'q' {
                'Salimos de la App'
                return
           }
     }
     pause
}
until ($input -eq 'q')
