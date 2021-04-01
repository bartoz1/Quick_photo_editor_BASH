#!/bin/bash

opcjeMenu=""
TMPZDJECIE
TMPPOKAZOWE
ZDJECIE
dostepneEfekty=(
        "Rysunek weglem"
        "Czarna dziura"
        "Farba oleinowa"
        "Zdjecie z Palaroida"
    )
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
    "8. Zapisz zmiany"
    "9. Koniec")
}
kopiuj() {
    ROZSZ=$(echo "${ZDJECIE##*.}")
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


# LOGIKA PROGRAMU
clear
powitanie
wczytaj_zdjecie
while [[ $WYBOR != "9. Koniec" ]]; do
    aktualizuj_menu
    WYBOR=$(zenity --list --column=Menu "${opcjeMenu[@]}" --height 370 --width 500)
    
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
        "${opcjeMenu[8]}") zapisz_zmiany;;
        "${opcjeMenu[9]}");;
        *) wyswietl_blad "Wpisz poprawna wartosc!";;
    esac;
    
done