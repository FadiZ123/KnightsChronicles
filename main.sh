#!/bin/bash
export pHP
export dmgDealt
export dmgTaken
clear

cat << EOF
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
                                The Knight's Chronicles
				    By Fadi Zubeideh
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
EOF

gametype(){     # Ask user to start a new game or load a save
        read -n 1 -p "Would you like to start a (n)ew game, or load a (s)ave? " newGame
        if [[ $newGame =~ [Nn] ]]; then
                potions=8
                arrows=10
                pHP=100
                encounternum=0  # 0=Guard, 1=rogue, 2=dark knight, 3=dragon.
                dmgDealt=0
                dmgTaken=0
                while true
                do
                        echo -e "\n"
                        read -p "Input your name: " username
                        if [[ $username =~ ^[a-zA-Z]{3,15}$ ]]; then
                                echo "Welcome $username."
                                break
                        else
                                echo "Name should be between 3 and 15 letters long."
                        fi
                done
        elif [[ $newGame =~ [Ss] ]]; then
                username=$(sqlite3 savedata.db "SELECT username FROM save")
                potions=$(sqlite3 savedata.db "SELECT potions FROM save")
                arrows=$(sqlite3 savedata.db "SELECT arrows FROM save")
                encounternum=$(sqlite3 savedata.db "SELECT encounternum FROM save")
                dmgDealt=$(sqlite3 savedata.db "SELECT dmgDealt FROM save")
                dmgTaken=$(sqlite3 savedata.db "SELECT dmgTaken FROM save")
                echo -e "\nWelcome $username."
        else
                echo -e "\nInvalid input. Starting a new game."
                potions=8
                arrows=10
                pHP=100
                encounternum=0  # 0=Guard, 1=rogue, 2=dark knight, 3=dragon.
                dmgDealt=0
                dmgTaken=0
                while true
                do
                        echo -e "\n"
                        read -p "Input your name: " username
                        if [[ $username =~ ^[a-zA-Z]{3,15}$ ]]; then
                                echo "Welcome $username."
                                break
                        else
                                echo "Name should be between 3 and 15 letters long."
                        fi
                done
        fi
}

encounter(){    # Generate a new encounter
        pHP=100
        case $encounternum in
                0)
                        eName="Prison Guard"
                        eAtk="slashes"
                        eDeath="The prison guard succumbs to his wounds, and you make your way out of the chamber."
                        eHP=60          # Enemy HP
                        eMinDmg=6       # Enemy damage ranges from eMinDmg to eMaxDmg
                        eMaxDmg=10
                ;;
                1)
                        eName="Rogue"
                        eAtk="stabs at"
                        eDeath="Badly hurt, the rogue scuttles away."
                        eHP=40          # Enemy HP
                        eMinDmg=12      # Enemy damage ranges from eMinDmg to eMaxDmg
                        eMaxDmg=20
                ;;
                2)
                        eName="Dark Knight"
                        eAtk="swings at"
                        eDeath="Despite his ironclad will, the dark knight is unable to fight any more and falls to the ground, defeated."
                        eHP=80          # Enemy HP
                        eMinDmg=10      # Enemy damage ranges from eMinDmg to eMaxDmg
                        eMaxDmg=15
                ;;
                3)
                        eName="Dragon"
                        eAtk="breathes fire on"
                        eDeath="You deal the killing blow and the dragon's massive body crashes to the earth."
                        eHP=150         # Enemy HP
                        eMinDmg=10      # Enemy damage ranges from eMinDmg to eMaxDmg
                        eMaxDmg=30
                ;;
        esac
}

status(){       # Checks for a win/lose condition: when player/computer runs out of health points
        if [[ $pHP -le 0 ]]; then ## checks if player lost the game
                return 2        # 2 = Lose
        elif [[ $eHP -le 0 ]]; then
                echo $eDeath
                let encounternum+=1
                return 1        # 1 = Win
        else
                echo "Your HP: $pHP"
                echo "$eName HP: $eHP"
        fi
}

statusstory(){  # Will print the correct story message between encounters.
        case $encounternum in
                0)
                        echo -e "\nYou are an exiled knight who wakes up confused inside of a prison cell in the King's giant castle."
                        echo "You find yourself equipped with a sword, a dagger, a bow with 10 arrows, and 8 health potions."
                        echo -e "You manage to break free of your cell and are caught by an angry prison guard.\n"
                ;;
                1)
                        echo -e "\nYou steal the guards keys and make an escape from the prison, however noticing a strategically placed note on the ground..."
                        echo "You pick up the note, and it reads: 'I, the princess, have been kidnapped and am trapped inside the dragon's castle. It is guarded by a terrifyingly powerful dragon and I need you to save me!'"
                        echo "You decide to take up this honorable request by her highness, and make a run for the exit of the King's castle."
                        echo -e "However you encounter a fierce rogue with 20 health just down the castle hall who runs at you hastily with a longsword, attempting to rob you!\n"
                ;;
                2)
                        echo -e "\nYou sneak past the King's guards and manage to leave his castle. Venturing out into the wilderness."
                        echo "You notice an eerie looking castle just beyond the horizon... That must be the Dragon's castle!"
                        echo "As you approach the castle doors, which is guarded by a mighty Dark Knight, you are spotted!"
                        echo -e "The Dark Knight pulls out his powerful sword and gets ready to swing at you.\n"
                ;;
                3)
                        echo -e "\nNow that the Dark Knight has been defeated, you slowly enter the doors of the Dragon's eerie Castle."
                        echo "From the dungeon just down the stairs, you hear a woman scream: 'Help me! I'm down here!'"
                        echo "That must be the princess! You run down the stairs and enter the dungeon."
                        echo -e "You are immediatley confronted by the terrifyngly powerful Dragon, guarding the princess who is trapped just behind it.\n"
                ;;
        esac
}

playerturn(){   # Takes input of which weapon to use. Returns integer 0-3.
        echo -n -e "\nWould you like to use your (d)agger, (s)word, (b)ow [$arrows], or (p)otion [$potions]? "
        while true
        do
                read -n 1 inp
                echo -e "\n"
                if [[ $inp == "d" ]]; then                      # Dagger
                        random 10 18
                        dmg=$?
                        echo "You pierce your foe in the abdomen with your dagger for $dmg damage."
                        let eHP-=$dmg
                        let dmgDealt+=$dmg
                        break
                elif [[ $inp == "s" ]]; then                    # Sword
                        random 1 100
                        prob=$?
                        if [[ prob -gt 25 ]]; then
                                random 15 25
                                dmg=$?
                                echo "Your powerful sword slash inflicts $dmg damage."
                                let eHP-=$dmg
                                let dmgDealt+=$dmg
                        else
                                echo "You swing your mighty sword, but miss."
                        fi
                        break
                elif [[ $inp == "b" && $arrows > 0 ]]; then     # Bow
                        random 1 100
                        prob=$?
                        if [[ prob -gt 60 ]]; then
                                random 20 50
                                dmg=$?
                                echo "You shoot your opponent in the chest for $dmg damage."
                                let eHP-=$dmg
                                let dmgDealt+=$dmg
                        else
                                echo "You draw your bow and fire, but your arrow does not hit its mark."
                        fi
                        let arrows-=1
                        break
                elif [[ $inp == "b" && $arrows -le 0 ]]; then
                        echo -n "You reach for an arrow, but find your quiver is empty. "
                elif [[ $inp == "p" && $potions > 0 ]]; then    # Potion
                        let pHP+=40
                        let potions-=1
                        break
                elif [[ $inp == "p" && $potions -le 0 ]]; then
                        echo -n "You reach for a potion, but find you have drank them all. "
                else
                        echo "Input (s), (d), (b), or (p)."
                fi
        done
}

computerturn(){
        random $eMinDmg $eMaxDmg
        dmg=$?
        let pHP-=$dmg
        let dmgTaken+=$dmg
        echo "The $eName $eAtk you for $dmg damage."
}

random(){       # Returns a random integer between $1 and $2, inclusive
        let r=$2+1-$1           # +1 to include both bounds
        let n=$1+$RANDOM%$r
        return $n
}

savegame(){
sqlite3 savedata.db << EOF
        DROP TABLE save;
        CREATE TABLE save (username VARCHAR(15), potions INT, arrows INT, encounternum INT, dmgDealt INT, dmgTaken INT);
        INSERT INTO save VALUES ("$username", $potions, $arrows, $encounternum, $dmgDealt, $dmgTaken);
EOF

cat << EOF

|----------------|
| Progress saved |
|----------------|
EOF

}

gameover(){
        python python.py # Calls python script
}


# ~~~~~ Main ~~~~~

gametype

while true
do
        savegame
        encounter
        statusstory
        status
        while true
        do
                playerturn
                status
                if [[ $? == "1" ]]; then
                        break
                fi
                computerturn
                status
                if [[ $? == "2" ]]; then
                        break
                fi
        done
        if [[ ($encounternum -gt 3 && $eHP -le 0) || $pHP -le 0 ]];
        then
                break
        fi
done

gameover

