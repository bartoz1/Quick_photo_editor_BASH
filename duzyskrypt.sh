#!/bin/bash
# Author           : Bartosz Zylwis ( s184477@student.pg.edu.pl )
# Created On       : 2021-04-06
# Last Modified By : Bartosz Zylwis ( s184477@student.pg.edu.pl )
# Last Modified On : 2021-04-18 
# Version          : 0.9
#
# Description      : Edytor zdjec pozwalajacy na dokonanie szybkich zmian na plikach graficznych
# Opis              
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

opcjeMenu=""
dostepneEfekty=(
        "Rysunek rysowany weglem"
        "Czarna dziura"
        "Farba oleinowa"
        "Zdjecie z Palaroida"
)
dostepnePolozenia=(
    "NorthWest"
    "North"
    "NorthEast"
    "West"
    "Center"
    "East"
    "SouthWest"
    "South"
    "SouthEast"
)
help() {
    echo "Pomoc do programu!"
    echo "Program QuickPhotoEditor służy do szybkiej edycji zdjęć. Po uruchomieniu skryptu należy wybrać zdjęcie, które ma być edytowane. Po poprawnym wybraniu wyświetla się menu główne z dostępnymi funkcjami programu. Dostępne opcje: podgląd, zmiana edytowanego pliku, blurowanie, obrót, zmiana rozmiaru(wymiarów), dodanie obramowania, dodanie znaku wodnego, dodanie efektów specjalnych, zapisanie zmian i wyjście z programu. "
    exit 0
}
version() {
    echo "Author: Bartosz Zylwis ( s184477@student.pg.edu.pl )"
    echo "Version: 0.8"
    exit 0
}
powitanie() {
    zenity --info --text "Witaj w edytorze zdjec\nWybierz zdjecie ktore chcesz edytowac" --title "Edytor zdjec" --width 300
}
wyswietl_blad() {
    TEKST=$1
    zenity --error --text "$TEKST" --width 300
}
wyswietl_info() {
    TEKST=$1
    zenity --info --text "$TEKST" --width 300
}
aktualizuj_menu() {
    opcjeMenu=(
    "Edytowany plik: $ZDJECIE"
    "1. Podglad zdjecia"
    "2. Zmien edytowany plik"
    "3. Blurowanie zdjecia"
    "4. Obroc zdjecie"
    "5. Zmien rozmiar zdjecia"
    "6. Dodaj specjalny efekt"
    "7. Dodaj obramowanie"
    "8. Dodaj znak wodny"
    "9. Zapisz zmiany"
    "10. Koniec")
}
aktualizuj_czcionke() {
    opcjeCzcionki=(
    "Tekst: $TEKST"
    "Czcionka: $CZCIONKA"
    "Rozmiar czcionki: $CZCIO_WIELK"
    "Kolor czcionki: $CZCIO_KOLOR"
    "Polozenie tekstu: $POLOZENIE"
    "Anuluj"
    "Zatwierdz")
}
kopiuj() {
    ROZSZ=$(echo "${ZDJECIE##*.}")                  #zczytanie rozszerzenia pliku
    TMPZDJECIE="/tmp/zdjecieedyt$$.$ROZSZ"          #zdjecie uzywane do edycji
    TMPPOKAZOWE="/tmp/zdjeciepokaz$$.$ROZSZ"        #zdjecie uzywane do pokazywania zmian
    cp "$ZDJECIE" "$TMPZDJECIE"
    cp "$ZDJECIE" "$TMPPOKAZOWE"

}
zapisz_zmiany() {
    cp "$TMPZDJECIE" "$ZDJECIE"
}
wczytaj_zdjecie() {
    ZDJECIE=$(zenity --file-selection --title="Wybierz zdjecie do edycji" --file-filter=""*.png" "*.jpg" "*.jpeg"")
    case $? in
            1)  wyswietl_blad "Nie wybrano zdjecia! Sprobuj ponownie"
                wczytaj_zdjecie;;
            -1) wyswietl_blad "Wystapil niespodziewany blad :("
                wczytaj_zdjecie;;
    esac
    kopiuj
}
zmiana_edytowanego() {
    zenity --question --title="Uwaga" --text "Czy jestes pewny, ze chcesz zmienic edytowany plik?\nObecne zmiany nie zostana zachowane!" --cancel-label="Wroc" --ok-label="TAK" --width 300
    if [ "$?" == 0 ]; then
        wczytaj_zdjecie
    fi
}
wyswietl_podglad() {
    display $TMPZDJECIE;
}
wyswietl_potwierdzenie() {
    display $TMPPOKAZOWE
    zenity --question --title="Uwaga" --text "Czy dodac efekt?" --cancel-label="Wroc" --ok-label="TAK" --width 300
    
    if [ "$?" == 0 ]; then
        cp "$TMPPOKAZOWE" "$TMPZDJECIE"
    else
        return 9
    fi
}
blurowanie_zdjecia() {
    MOC=$(zenity --scale --text "Moc blurowania(0-10)" --min-value 0 --max-value 10 --value 5)
    if [ "$?" != 0 ]; then return 0; fi     #obsluzenie przycisku cancel/anuluj

    convert $TMPZDJECIE -blur "0x$MOC" $TMPPOKAZOWE
    wyswietl_potwierdzenie
    if [ "$?" == 9 ]; then
        blurowanie_zdjecia
    fi
}
obramowanie_zdjecia() {
    
    GRUBOSC=$(zenity --scale --text "Szerokosc ramki" --min-value 1 --max-value 200 --value 5)
    if [ "$?" != 0 ]; then return 0; fi     #obsluzenie przycisku cancel/anuluj
    KOLOR=$(zenity --color-selection --show-palette)
    if [ "$?" != 0 ]; then return 0; fi     #obsluzenie przycisku cancel/anuluj
    convert -border "$GRUBOSC" -bordercolor "$KOLOR" $TMPZDJECIE $TMPPOKAZOWE
    wyswietl_potwierdzenie
    if [ "$?" == 9 ]; then
        obramowanie_zdjecia
    fi
}
rozmiar_zdjecia() {
    ROZMIAR=$(zenity --forms --title="Zmiana rozmiaru" --text="Nowy rozmiar zdjecia" --separator="x" --add-entry="szerokosc" --add-entry="wysokosc")
    if [ "$?" != 0 ]; then return 0; fi     #obsluzenie przycisku cancel/anuluj
    convert "$TMPZDJECIE" -resize "$ROZMIAR"! "$TMPPOKAZOWE"
    
    if [ "$?" != 0 ]; then
        wyswietl_blad "Podawane wartosci musza byc liczbami!"
        rozmiar_zdjecia
    fi
    wyswietl_potwierdzenie
    if [ "$?" == 9 ]; then
        rozmiar_zdjecia
    fi
}
obrot_zdjecia() {
    OBROT=$(zenity --scale --text "Rotacja (stopnie)" --min-value 0 --max-value 360 --value 90)
    if [ "$?" != 0 ]; then return 0; fi     #obsluzenie przycisku cancel/anuluj
    convert "$TMPZDJECIE" -rotate "$OBROT" "$TMPPOKAZOWE"
    
    wyswietl_potwierdzenie
    if [ "$?" == 9 ]; then
        obrot_zdjecia
    fi
}
efekty_zdjecia() {
    
    EFEKTY=$(zenity --list --column=Menu "${dostepneEfekty[@]}" --height 270 --width 500)
    if [ "$?" != 0 ]; then return 0; fi     #obsluzenie przycisku cancel/anuluj
    case $EFEKTY in
        "${dostepneEfekty[0]}") 
            WYBRANY="-charcoal"
            MOC=$(zenity --scale --text "Moc efektu" --min-value 1 --max-value 10 --value 5);;
        "${dostepneEfekty[1]}") 
            WYBRANY="-implode"
            MOC=$(zenity --scale --text "Moc efektu" --min-value 1 --max-value 3 --value 1);;
        "${dostepneEfekty[2]}") 
            WYBRANY="-paint"
            MOC=$(zenity --scale --text "Moc efektu" --min-value 1 --max-value 10 --value 5);;
        "${dostepneEfekty[3]}") 
            WYBRANY="-polaroid"
            MOC="0";;
        *) 
            wyswietl_blad "Wpisz poprawna wartosc!"
            efekty_zdjecia;;
    esac

    convert "$TMPZDJECIE" "$WYBRANY" "$MOC" "$TMPPOKAZOWE"
    
    wyswietl_potwierdzenie
    if [ "$?" == 9 ]; then
        efekty_zdjecia
    fi
}
wczytaj_tekst() {
    TEKST=$(zenity --entry --title="Ustawienie znaku wodnego" --text="Tekst znaku wodnego")
}
rozmiar_czcionki() {
    TMP_CZCIO_WIELK=$(zenity --scale --text "Rozmiar czcionki" --min-value 1 --max-value 200 --value 20)
    if [ "$?" == 0 ] && [ "$TMP_CZCIO_WIELK" != "" ]; then 
        CZCIO_WIELK=$TMP_CZCIO_WIELK 
    fi     
}
kolor_czcionki() {
    TMP_CZCIO_KOLOR=$(zenity --color-selection --title="Kolor czcionki" --show-palette)
    if [ "$?" == 0 ] && [ "$TMP_CZCIO_KOLOR" != "" ]; then 
        CZCIO_KOLOR=$TMP_CZCIO_KOLOR 
    fi     
}

zmien_czcionke() {
    TMP=$(convert -list font | grep Font | cut -d ":" -f2 | sed 's/ //g')
    readarray -t DOSTEPNE_CZCIONKI <<<"$TMP"
    TMP_WYBOR=$(zenity --list --column=Czcionki "${DOSTEPNE_CZCIONKI[@]}" --text="Wybierz czcionke do tekstu" --title="Zmiana czcionki" --height 370 --width 500)
    
    if [ "$TMP_WYBOR" != "" ]; then
        CZCIONKA=$TMP_WYBOR
    fi
}
polozenie_znaku_wodnego() {
    
    ODP=$(zenity --list --column=Menu "${dostepnePolozenia[@]}" --text="Wybiez polozenie znaku wodnego" --title="Zmiana polozenia" --height 330 --width 500)
    if [ "$?" == 0 ] && [ "$ODP" != "" ]; then 
        POLOZENIE=$ODP 
    fi 

}
znak_wodny_zdjecia() {
    TEKST=$(zenity --entry --title="Tekst znaku wodnego" --text="Wprowadz znak wodny")
    if [ "$?" != 0 ]; then
        return 12
    fi
    CZCIONKA="FreeSans"
    CZCIO_WIELK=$(gsettings get org.gnome.desktop.interface monospace-font-name |  sed "s/'//g" | cut -d " " -f2)
    CZCIO_KOLOR='black'
    ZW_WYBOR="aha"
    POLOZENIE="Center"
    while [[ $ZW_WYBOR != "${opcjeCzcionki[6]}" ]]; do
        aktualizuj_czcionke
        ZW_WYBOR=$(zenity --list --column=Menu "${opcjeCzcionki[@]}" --height 370 --width 500)
        if [ "$?" != 0 ]; then
            return 0
        fi 
        case $ZW_WYBOR in
            "${opcjeCzcionki[0]}") wczytaj_tekst;;
            "${opcjeCzcionki[1]}") zmien_czcionke;;
            "${opcjeCzcionki[2]}") rozmiar_czcionki;;
            "${opcjeCzcionki[3]}") kolor_czcionki;;
            "${opcjeCzcionki[4]}") polozenie_znaku_wodnego;;
            "${opcjeCzcionki[5]}") return 0;;
            "${opcjeCzcionki[6]}")
            convert $TMPZDJECIE -font $CZCIONKA -pointsize $CZCIO_WIELK -draw "gravity $POLOZENIE fill $CZCIO_KOLOR text 100,50 \"$TEKST\"" $TMPPOKAZOWE
                wyswietl_potwierdzenie
                if [ "$?" == 9 ]; then
                    ZW_WYBOR="kontynuuj"
                fi
            ;;
            *) wyswietl_blad "Wpisz poprawna wartosc!";;
        esac;
    done
}

main() {            #glowna petla programu

    clear
    powitanie
    wczytaj_zdjecie
    WYBOR="start"
    while [[ $WYBOR != "${opcjeMenu[10]}" ]]; do
        aktualizuj_menu
        WYBOR=$(zenity --list --column=Menu "${opcjeMenu[@]}" --title="SUPER Photo Editor Lite" --text="Wybierz opcje z ponizszego menu" --height 370 --width 500)
        
        if [ "$?" != 0 ]; then
            exit
        fi      
        clear
        case $WYBOR in
            "${opcjeMenu[0]}") wczytaj_zdjecie;;
            "${opcjeMenu[1]}") wyswietl_podglad;;
            "${opcjeMenu[2]}") zmiana_edytowanego;;
            "${opcjeMenu[3]}") blurowanie_zdjecia;;
            "${opcjeMenu[4]}") obrot_zdjecia;;
            "${opcjeMenu[5]}") rozmiar_zdjecia;;
            "${opcjeMenu[6]}") efekty_zdjecia;;
            "${opcjeMenu[7]}") obramowanie_zdjecia;;
            "${opcjeMenu[8]}") znak_wodny_zdjecia;;
            "${opcjeMenu[9]}") zapisz_zmiany;;
            "${opcjeMenu[10]}");;
            *) wyswietl_blad "Wpisz poprawna wartosc!";;
        esac;
        
    done
}

while getopts hvf:q OPCJE; do
    case $OPCJE in
        h) help;;
        v) version;;
        *) echo "Nieznana opcja"
            exit 0;;
    esac
done

main