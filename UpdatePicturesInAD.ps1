#Hent alle users i es.lan -> ERST -> Users -> Internal, hvor 'State' er sat til 'Danmark'.
#Hent kun deres 'mail' og deres SamAccountName properties, da dette er alt der skal bruges.
$users = Get-ADUser -Filter "State -eq 'Danmark'" -SearchBase "OU=OU=xxxx" -Properties "mail", SamAccountName

#Opret et log variable
$log = "START: " + (Get-Date -UFormat "%d-%m-%Y %T") + "`r`n"

#Kør igennem alle brugerne
ForEach ($user in $users) {

    #Tag emailen for brugeren, og find bogstaverne foran @
    #For eksempel: AbcDef@erst.dk bliver til AbcDef
    $email = $user.mail
    $emailletters = $email.Substring(0,$email.IndexOf("@"))

    #Fortæl hvor billedet ligger, ud fra email bogstaverne
    $photopath = "C:\Users\frl\Erhvervsstyrelsen\Share - Inside billeder\" + $emailletters + ".jpg"

    #Tjek om der findes en aktuel fil, der hvor billedet skulle ligge
    if (Test-Path -Path $photopath -PathType leaf) {

        #Findes billedet, tilføj det til brugerens thumbnailPhoto
        $photo = [byte[]](Get-Content $photopath -Encoding byte)
        Set-ADUser $user.SamAccountName -Replace @{thumbnailPhoto=$photo}

    } else {

        #Findes billedet ikke, tilføj fejlen til log variable
        #Ekskluder følgende email bogstaver, så de ikke danner fejl:
        #f.eller
        #Flere kan tilføjes på følgende måde (skal være lowercase):
        # $excludeusers = @(
        #     "f.eller",
        #     "abcdef",
        #     "ghijkl"
        # )
        $excludeusers = @(
            "f.eller"
        )

        if ($excludeusers -match $emailletters) {
            #Brugeren skal ikke tilføjes til loggen, da brugeren er i ekskluderet bruger.
        } else {
            #Brugeren skal tilføjes til loggen.
            $log = $log + ($emailletters + " (" + $user.SamAccountName + "): photo not found!") + "`r`n"
        }

    }

}

#Skriv log til en log fil for dagens dato
$log = $log + "END: " + (Get-Date -UFormat "%d-%m-%Y %T") + "`r`n"
$logfile = "C:\Scripts\photo-errors\photo-errors-" + (Get-Date -UFormat "%d-%m-%Y") + ".log"
Set-Content -Path $logfile -Value $log