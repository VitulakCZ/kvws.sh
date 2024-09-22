#!/bin/bash

penize=0
vojaci=0
penize=0
kola=1
obsadit=0
banka=0
penize_za_kolo=2

koupit_vojaky () {
    echo -n "Máš $vojaci vojáků, peněz $penize, cena za 1000 vojáků je 1 mld. Kolik jich chceš koupit? "
    read pocet
    re='^[0-9]+$'
    if [[ ! $pocet =~ $re ]]; then
        echo -e "ERROR: Nesprávné zadání!\n"
    elif [[ $(($pocet % 1000)) != 0 ]]; then
        echo -e "Nezadal jsi číslo dělitelné 1000!\n"
    elif [[ $(($penize < $(($pocet / 1000)))) == 1 ]]; then
        echo -e "NEMÁŠ DOSTATEK FINANCÍ!\n"
    else
        penize=$(($penize - ($pocet / 1000)))
        vojaci=$(($vojaci + $pocet))
        echo -e "Nakoupeno $pocet vojáků.\nCelkem máš $vojaci vojáků, zbývá ti $penize peněz.\n"
    fi
}

valka () {
    echo -n "Musíš obsadit ještě $obsadit území. Na jedno území potřebuješ 2000 vojáků, chceš zaútočit? A = Ano, N = Ne: "
    read obsadit_str
    obsadit_str=${obsadit_str^^}
    if [[ "$obsadit_str" = "A" ]]; then
        if [[ $(($vojaci < 2000)) = 1 ]]; then
            echo -e "NEMÁŠ DOSTATEK VOJÁKŮ!\n"
        else
            vojaci=$(($vojaci - 2000))
            obsadit=$(($obsadit - 1))
            echo "Zaútočil jsi! Zbývá ti $vojaci vojáků."
            if [[ $obsadit == 0 ]]; then
                echo -en "GRATULACE!!! Dohrál jsi hru!! Jsi dobrý!!\nStiskem ENTER pokračuj: "
                read
                exit 0
            fi
        fi
    elif [[ "$obsadit" = "N" ]]; then
        echo -e "NE!\n"
    else
        echo -e "ERROR: Nesprávné zadání!\n"
    fi
}

investovat () {
    echo -en "Kolik chceš investovat?\n6 (+1 peníz za kolo)\n10 (+2 peníze za kolo): "
    read investice
    err=0
    if [[ ! $investice = 6 ]] && [[ ! $investice = 10 ]]; then
        echo -e "ERROR: Nesprávné zadání!\n"
        err=1
    elif [[ $investice = 6 ]]; then
        if [[ $penize_za_kolo > 4 ]] && [[ ! "$obtiznost" = "E" ]] || [[ $(($penize_za_kolo > 9)) == 1 ]]; then
            echo -e "Už jsi investoval až moc peněz!\n"
            err=1
        fi
    elif [[ $investice = 10 ]]; then
        if [[ $penize_za_kolo > 3 ]] && [[ ! "$obtiznost" = "E" ]] || [[ $(($penize_za_kolo > 8)) == 1 ]]; then
            echo -e "Už jsi investoval až moc peněz!\n"
            err=1
        fi
    fi
    if [[ $err = 0 ]] && [[ $(($penize < $investice)) == 1 ]]; then
        echo -e "NEMÁŠ DOSTATEK FINANCÍ!\n"
    elif [[ $err = 0 ]]; then
        penize=$(($penize - $investice))
        penize_za_kolo=$(($penize_za_kolo + $(($investice / 5))))
        if [[ $(($penize_za_kolo < 5)) == 1 ]]; then
            echo -e "$penize_za_kolo peníze za kolo\n"
        else
            echo -e "$penize_za_kolo peněz za kolo\n"
        fi
    fi
}

banka () {
    if [[ $banka > 5 ]]; then
        echo -e "Už sis půjčil až moc peněz!\n"
    else
        echo -n "Kolik si chceš půjčit? 1, 2, 3 mld? "
        read pujcit
        if [[ $pujcit = 1 ]] || [[ $pujcit = 2 ]] || [[ $pujcit = 3 ]]; then
            if [[ $(($(($banka + $(($pujcit * 2)))) > 6)) = 1 ]]; then
                echo "Nemůžeš si tolik půjčit!"
            else
                penize=$(($penize + $pujcit))
                banka=$(($banka + $(($pujcit * 2))))
            fi
            echo -e "Dluh v tento moment máš $banka mld.\n"
        else
            echo -e "ERROR: Nesprávné zadání!\n"
        fi
    fi
}

dalsi_kolo () {
    kola=$(($kola + 1))
    if [[ $kola = 50 ]]; then
       echo -e "Nestihl jsi dohrát hru pod 50 kol.\nGAME OVER";
        exit 0
    fi
    penize=$(($penize + $penize_za_kolo - $banka))
    banka=0
    for kolo in {0..50..5}; do
        [[ ! $kolo = $kola ]] && continue
        if [[ "$obtiznost" = "E" ]] && [[ ! $(($kolo % 10)) = 0 ]]; then
            :
        elif [[ $(($vojaci < 2000)) = 1 ]] && [[ "$obtiznost" = "H" ]] || [[ $(($vojaci < 1000)) = 1 ]]; then
            echo -e "Zaútočili na tebe, nemáš dostatek vojáků na protiútok.\nGAME OVER"
            exit 0
        else
            vojaci=$(($vojaci - 1000))
            [[ "$obtiznost" = "H" ]] && vojaci=$(($vojaci - 1000))
            echo -e "Zaútočili na tebe! Nově máš $vojaci vojáků!\n"
            kola=$(($kola + 1))
        fi
    done
}

while [[ 1 ]]; do
    echo -en "Na jakou chceš hrát obtížnost\nE = Easy\nN = Normal\nH = Hard: "
    read obtiznost_str
    obtiznost=${obtiznost_str^^}
    if [[ "$obtiznost" = "E" ]]; then
        echo -e "EASY obtížnost\n- Začínáte s 3 mld. penězi\n- Začínáte s 2000 vojáky\n- Dokud neinvestujete, získáváte 2 mld. peněz za kolo\n- Chcete-li vyhrát, musíte získat 30 území\n- Investovat můžete do 10 peněz za kolo\n- Invaze do vaší země se konají každých 10 kol\n- Invaze jsou vždy po 1000 vojácích"
        penize=3
        vojaci=2000
        obsadit=30
        break

    elif [[ "$obtiznost" = "N" ]]; then
        echo -e "NORMAL obtížnost\n- Začínáte s 3 mld. penězi\n- Nezačínáte s žádnými vojáky\n- Dokud neinvestujete, získáváte 2 mld. peněz za kolo\n- Chcete-li vyhrát, musíte získat 57 území\n- Investovat můžete do 5 peněz za kolo\n- Invaze do vaší země se konají každých 5 kol\n- Invaze jsou vždy po 1000 vojácích"
        penize=3
        obsadit=57
        break

    elif [[ "$obtiznost" = "H" ]]; then
        echo -e "HARD obtížnost\n- Nezačínáte s žádnými penězi\n- Nezačínáte s žádnými vojáky\n- Dokud neinvestujete, získáváte 2 mld. peněz za kolo\n- Chcete-li vyhrát, musíte získat 70 území\n- Investovat můžete do 5 peněz za kolo\n- Invaze do vaší země se konají každých 5 kol\n- Invaze jsou vždy po 2000 vojácích"
        obsadit=70
        break

    else
        echo -e "ERROR: Nesprávné zadání!\n"
    fi
done


echo -n "Stiskem ENTER pokračuj: "
read

echo -e "Toto je vylepšená verze hry textova_hra.py. Jestli chcete mít zážitek ze hry textova_hra, jako takový, stáhněte si KV OS BETA 0.6.\n"
while [[ 1 ]]; do
    echo "$kola. KOLO!"
    echo -n "K = Koupit vojáky, V = Válka, I = Investovat, B = Banka, D = Další kolo, E = Exit: "
    read input
    input=${input^^}
    if [[ "$input" = "K" ]]; then
        koupit_vojaky
    elif [[ "$input" = "V" ]]; then
        valka
    elif [[ "$input" = "I" ]]; then
        investovat
    elif [[ "$input" = "B" ]]; then
        banka
    elif [[ "$input" = "D" ]]; then
        dalsi_kolo
    elif [[ "$input" = "E" ]]; then
        exit
    else
        echo -e "ERROR: Nesprávné zadání!\n"
    fi
done
