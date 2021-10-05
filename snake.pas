program snake;

uses crt {couleur,goto}, keyboard {lire une touche}, dos {temps}, sysutils {fichier};

const largeurmax=13;
	hauteurmax=13;
	proportionmur=10;
	maxse=3; {max score enregistés}
	minlvl=0;
	maxlvl=7;

type tabt1=array [1..largeurmax,1..hauteurmax] of integer;
	tabt2=array [1..2,1..100] of integer;

type senst=(droite,gauche,haut,bas);

Type score1=record
	namescore:array[minlvl..maxlvl,1..maxse] of string;
	scorenbr:array[minlvl..maxlvl,1..maxse] of integer;
end;

//choose level
procedure choixniveau(var lvl:integer);

begin
	repeat
		write('Choose a level between ',minlvl,' and ',maxlvl,' (10 to exit, 11 to return to menu) : ');
		readln(lvl);
		
		case lvl of
		10:begin
			writeln('Good by ! =D');
			exit;
		end;
		11:begin
			exit
		end;
		end;
		clrscr;
		If ((lvl<minlvl) or (lvl>maxlvl)) then writeln(lvl,' is not between 2 and ',maxlvl,' : ');
	until ((lvl>-1) and (lvl<maxlvl+1));
end;

//chose color
procedure choixcouleur(var couleur:char);

var c:integer;
	K:TKeyEvent;

begin
	InitKeyBoard();
	writeln('Choisisez votre couleur :');
	writeln('');
	writeln('Blanc [ ]');
	writeln('Bleu  [ ]');
	writeln('');
	writeln('Touche ESPACE pour selectioner.');
	gotoxy(8,3);
	c:=1;
	
	repeat
		K:=GetKeyEvent();
		K:=TranslateKeyEvent(K);
		if ((KeyEventToString(K) = 'Up') and (wherey>3)) then
			GotoXY(8,wherey-1);
		if ((KeyEventToString(K) = 'Down') and (wherey<4))then
			GotoXY(8,wherey+1);
		c:=wherey;
	until (KeyEventToString(K) = ' ');
	
	if c=3 then couleur:='w';
	if c=4 then couleur:='b';
end;

//initialise grid
procedure initialisationgrille(lvl:integer; var tab1:tabt1; var tab2:tabt2; var sens:senst; var posx,posy:integer);

var i,j,x,y:integer;

begin
	posx:=largeurmax div 2; 
	posy:=hauteurmax div 2;
	
	randomize; {2 et -1 pour ne pas avoir de mur sur les bords}
	if lvl<>0 then
	begin
		for i:=2 to hauteurmax-1 do
			for j:=2 to largeurmax-1 do
			begin
				x:=random(proportionmur-lvl); {0:serpent; 1:rien; 2:mur; 3:fruit}
				if ((x=2) and (i<>2) and (i<>largeurmax-1) and (j<>2) and (j<>hauteurmax-1)) then
					tab1[i,j]:=2
				else tab1[i,j]:=1;
			end;
	end
	else if lvl=0 then
	begin
		for i:=2 to hauteurmax-1 do
			for j:=2 to largeurmax-1 do
				tab1[i,j]:=1;
	end;
	
	for i:=1 to hauteurmax do {pour le cadre}
	begin
		tab1[1,i]:=2;
		tab1[largeurmax,i]:=2;
		tab1[i,1]:=2;
		tab1[i,hauteurmax]:=2;
	end;
	
	tab2[1,1]:=posx; {pour le snake}
	tab2[2,1]:=posy;
	tab2[1,2]:=posx-1;
	tab2[2,2]:=posy;
	tab1[posx-1,posy]:=0;
	tab1[posx,posy]:=0;
	
	for i:=posx+1 to largeurmax-1 do {pour la ligne sans murs}
	begin
		tab1[i,posy]:=1;
	end;
	
	repeat {pour le fruit}	{0:serpent; 1:rien; 2:mur; 3:fruit}
		x:=random(largeurmax-3)+2;
		y:=random(hauteurmax-3)+2;
		if tab1[x,y]=1 then tab1[x,y]:=3;
	until tab1[x,y]=3;
	
	sens:=droite;
end;

//displqy grid
procedure affichagegrille(tab1:tabt1; couleur:char);

var col,lin:integer;

begin
	clrscr;
	for lin:=1 to largeurmax do
	for col:=1 to hauteurmax do
	begin
		if ((tab1[col,lin]=0) and (couleur='b')) then textbackground(blue);
		if ((tab1[col,lin]=0) and (couleur='w')) then textbackground(white);
		if tab1[col,lin]=2 then textbackground(red);
		if tab1[col,lin]=3 then textbackground(green);
		if col=largeurmax then writeln ('  ') else write ('  ');
		textbackground(black);
	end;
end;

//displacement
procedure deplacement(var sens:senst; var posx,posy,score:integer; var tab1:tabt1; var tab2:tabt2; var victoire:boolean);

var score1,x,y:integer;
var	K:TKeyEvent;

begin
	randomize;
	score1:=score;
	InitKeyBoard();
	delay(5); {obligatoire pour que la procedure soit prise en compte dans la boucle repeat dans jeu}
	if keypressed then 
		repeat
			K:=GetKeyEvent();
			K:=TranslateKeyEvent(K);
			if KeyEventToString(K) = 'Up' then
			begin
				if ((tab1[posx,posy-1]=2) or (tab1[posx,posy-1]=0)) then
					victoire:=false;
				if tab1[posx,posy-1]=3 then
				begin
					score:=score+1;
					posy:=posy-1;
					tab2[1,score]:=tab2[1,score-1];
					tab2[2,score]:=tab2[2,score-1]-1;
					tab1[posx,posy]:=0;
				end;
				sens:=haut;
			end
			else if KeyEventToString(K) = 'Down' then
			begin
				if ((tab1[posx,posy+1]=2) or (tab1[posx,posy+1]=0)) then
					victoire:=false;
				if tab1[posx,posy+1]=3 then
				begin
					score:=score+1;
					posy:=posy+1;
					tab2[1,score]:=tab2[1,score-1];
					tab2[2,score]:=tab2[2,score-1]+1;
					tab1[posx,posy]:=0;
				end;
				sens:=bas;
			end
			else if KeyEventToString(K) = 'Left' then
			begin
				if ((tab1[posx-1,posy]=2) or (tab1[posx-1,posy]=0)) then
					victoire:=false;
				if tab1[posx-1,posy]=3 then
				begin
					score:=score+1;
					posx:=posx-1;
					tab2[1,score]:=tab2[1,score-1]-1;
					tab2[2,score]:=tab2[2,score-1];
					tab1[posx,posy]:=0;
				end;
				sens:=gauche;
			end
			else if KeyEventToString(K) = 'Right' then {droite}
			begin
				if ((tab1[posx+1,posy]=2) or (tab1[posx+1,posy]=0)) then
					victoire:=false;
				if tab1[posx+1,posy]=3 then
				begin
					score:=score+1;
					posx:=posx+1;
					tab2[1,score]:=tab2[1,score-1]+1;
					tab2[2,score]:=tab2[2,score-1];
					tab1[posx,posy]:=0;
				end;
				sens:=droite;
			end;
		until (KeyEventToString(K) = 'Up') or (KeyEventToString(K) = 'Down') or (KeyEventToString(K) = 'Right') or (KeyEventToString(K) = 'Left');
	DoneKeyBoard();
	
	if score1<>score then
	begin
		repeat
			x:=random(largeurmax-3)+2;
			y:=random(hauteurmax-3)+2;
			if tab1[x,y]=1 then tab1[x,y]:=3; {0:serpent; 1:rien; 2:mur; 3:fruit}
		until tab1[x,y]=3;
	end;
end;

//displacement snake
procedure depacementsnake(var posx,posy,score:integer; sens:senst; var tab1:tabt1; var tab2:tabt2; var victoire:boolean);

var i,x,y,score1:integer;

begin {0:serpent; 1:rien; 2:mur; 3:fruit}
	randomize;
	score1:=score;
	
	tab1[tab2[1,1],tab2[2,1]]:=1;
	for i:=1 to score-1 do
	begin
		tab2[1,i]:=tab2[1,i+1];
		tab2[2,i]:=tab2[2,i+1];
	end;
	
	if sens=haut then
	begin
		posy:=posy-1;
		if ((tab1[posx,posy]=2) or (tab1[posx,posy]=0)) then
			victoire:=false;
		if tab1[posx,posy]=3 then score:=score+1;
		tab2[1,score]:=posx;
		tab2[2,score]:=posy;
	end;
	if sens=bas then
	begin
		posy:=posy+1;
		if ((tab1[posx,posy]=2) or (tab1[posx,posy]=0)) then
			victoire:=false;
		if tab1[posx,posy]=3 then score:=score+1;
		tab2[1,score]:=posx;
		tab2[2,score]:=posy;
	end;
	if sens=gauche then
	begin
		posx:=posx-1;
		if ((tab1[posx,posy]=2) or (tab1[posx,posy]=0)) then victoire:=false;
		if tab1[posx,posy]=3 then score:=score+1;
		tab2[1,score]:=posx;
		tab2[2,score]:=posy;
	end;
	if sens=droite then
	begin
		posx:=posx+1;
		if ((tab1[posx,posy]=2) or (tab1[posx,posy]=0)) then victoire:=false;
		if tab1[posx,posy]=3 then score:=score+1;
		tab2[1,score]:=posx;
		tab2[2,score]:=posy;
	end;
	
	if score1<>score then
	begin
		repeat
		x:=random(largeurmax-3)+2;
		y:=random(hauteurmax-3)+2;
		if tab1[x,y]=1 then tab1[x,y]:=3; {0:serpent; 1:rien; 2:mur; 3:fruit}
		until tab1[x,y]=3;
	end;
	
	for i:=1 to score do
		tab1[tab2[1,i],tab2[2,i]]:=0;
end;

//menu
procedure menu(var gojeu,goscore,goregles:boolean);

var c:integer;
	K:TKeyEvent;

Begin
	InitKeyBoard();
	gojeu:=false;
	goscore:=false;
	goregles:=false;
	
	writeln('SNAKE par NINJA7V');
	writeln('');
	{liste des choix}
	writeln('Jouer  [ ]');
	writeln('Scores [ ]');
	writeln('Regles [ ]');
	writeln('');
	writeln('Touche ESPACE pour selectioner.');
	gotoxy(9,3);
	c:=1;
	
	repeat
		K:=GetKeyEvent();
		K:=TranslateKeyEvent(K);
		if ((KeyEventToString(K) = 'Up') and (wherey>3)) then	GotoXY(9,wherey-1);
		if ((KeyEventToString(K) = 'Down') and (wherey<5))then	GotoXY(9,wherey+1);
		c:=wherey;
	until (KeyEventToString(K) = ' ');
	
	DoneKeyBoard();
	case c of
		3:gojeu:=true;
		4:goscore:=true;
		5:goregles:=true;
	end;
End;

//rules
procedure regles (var retour:integer);

const l=5;
var	tab1:tabt1;
	tab2:tabt2;
	couleur:char;
	posx,posy,pos,c:integer;
	sens:senst;
	K:TKeyEvent;

begin
	clrscr;
	couleur:='w';
	sens:=droite;
	initialisationgrille(l,tab1,tab2,sens,posx,posy);
	affichagegrille(tab1,couleur);
	writeln('');
	writeln('Le but est de grandir le plus possible en attrapant les points.');
	writeln('Attention à ne pas rentrer dans les murs !');
	writeln('Tu peux mettre PAUSE en apuyant sur n importe quelle touche.');
	writeln('');
	writeln('Menu [ ]');
	writeln('Exit [ ]');
	writeln('');
	writeln('Touche ESPACE pour selectioner.');
	pos:=wherey;
	gotoxy(7,pos-4);
	c:=1;
	InitKeyBoard();
	repeat
		K:=GetKeyEvent();
		K:=TranslateKeyEvent(K);
		if ((KeyEventToString(K) = 'Up') and (wherey>pos-4)) then
			GotoXY(7,wherey-1);
		if ((KeyEventToString(K) = 'Down') and (wherey<pos-3))then
			GotoXY(7,wherey+1);
		c:=wherey;
	until (KeyEventToString(K) = ' ');
	
	DoneKeyBoard();
	if (c=pos-4) then retour:=0;
	if (c=pos-3) then retour:=1;
end;

//saving score
procedure enregistrementscore(lvl,score:integer); 

var tabscore:score1;
	pseudo:string;
	i,j:integer;
	classement:file of score1;

begin
	if (lvl>minlvl-1) and (lvl<maxlvl+1) then
	begin
		{creation du fichier score}
		if not(FileExists('fichierscoresnake')) then
		begin
			assign(classement, 'fichierscoresnake');
			rewrite(classement);
			
			for i:=1 to maxse do
				for j:=minlvl to maxlvl do
				begin
					tabscore.scorenbr[j,i]:=0;
					tabscore.namescore[j,i]:='user';
				end;
				write(classement,tabscore);		
				close(classement);
	end;
	
	assign(classement, 'fichierscoresnake');
	reset(classement);
	Read(classement, tabscore);
	
	if (score<tabscore.scorenbr[lvl,maxse]) then
	begin
		rewrite(classement);
		write('Good score ! Pseudo : ');
		Readln(pseudo);
		i:=maxse;
		repeat
			if (score<tabscore.scorenbr[lvl,i-1]) then
			begin
				tabscore.scorenbr[lvl,i]:=tabscore.scorenbr[lvl,i-1];
				tabscore.namescore[lvl,i]:=tabscore.namescore[lvl,i-1];
				i:=i-1;
			end;
			until (score-2>=tabscore.scorenbr[lvl,i-1]) or (i=1);
			
			tabscore.scorenbr[lvl,i]:=score-2;
			tabscore.namescore[lvl,i]:=pseudo;
			write(classement, tabscore);
		end;
		close(classement);
	end;
End;

//display scores
procedure affichagescores(var lvl:integer);

var classement:file of score1;
	i,j,l,c,pos:integer;
	K:TKeyEvent;
	tabscore:score1;
Begin
	clrscr;
	assign(classement, 'fichierscoresnake');
	reset(classement);
	Read(classement, tabscore);
	
	repeat
		write('Witch level do you want to check ? (beween ',minlvl,' to ',maxlvl,') ');
		read(l);
		If ((l<minlvl) or (l>maxlvl)) then
		begin
			clrscr;
			writeln(l,' is not between ',minlvl,' and ',maxlvl,'.');
		end;
	until (l>minlvl-1) and (l<maxlvl+1);
	writeln('');
	for i:=1 to maxse do
	begin
		if (tabscore.namescore[l,i]<>'user') then
			write(i,'- ',tabscore.namescore[l,i],' : ',tabscore.scorenbr[l,i],' / ');
	end;
	
	close(classement);
	
	writeln('');
	writeln('');
	{list of differents choices}
	writeln('Reset score [ ]');
	writeln('Menu        [ ]');
	writeln('Exit        [ ]');
	writeln('');
	writeln('Press SPACEBAR to select.');
	pos:=wherey;
	gotoxy(14,wherey-5);
	c:=1;
	InitKeyBoard();
	repeat
		K:=GetKeyEvent();
		K:=TranslateKeyEvent(K);
		if ((KeyEventToString(K) = 'Up') and (wherey>pos-5)) then
			GotoXY(14,wherey-1);
		if ((KeyEventToString(K) = 'Down') and (wherey<pos-3))then
			GotoXY(14,wherey+1);
		c:=wherey;
	until (KeyEventToString(K) = ' ');
	
	DoneKeyBoard();
	if (c=pos-5) then
	begin
		assign(classement, 'fichierscoresnake');
		reset(classement);
		rewrite(classement);
		for i:=1 to maxse do
			for j:=minlvl to maxlvl do
			begin
				tabscore.scorenbr[j,i]:=0;
				tabscore.namescore[j,i]:='user';
			end;
		write(classement,tabscore);
	close(classement);
	lvl:=1;
	end;
	if (c=pos-3) then lvl:=0;
	if (c=pos-4) then lvl:=1;
End;

//game
procedure jeu(var tab1:tabt1; var tab2:tabt2; var score,retour:integer; var victoire:boolean);

var lvl,posx,posy,pos,c1,score1:integer;
	sens,sens1:senst;
	couleur:char;
	K:TKeyEvent;
	t1,t2:longint;
	h,m,s,c:word;

begin
	clrscr;
	choixniveau(lvl);
	If lvl=10 then retour:=1;
	If ((lvl=11) or (lvl=10)) then exit;
	choixcouleur(couleur);
	initialisationgrille(lvl,tab1,tab2,sens,posx,posy);
	
	score1:=2;
	sens1:=sens;
	repeat
		depacementsnake(posx,posy,score,sens,tab1,tab2,victoire);
		gettime (h,m,s,c);
		t1:=(h*36000+m*6000+s*100+c);
		affichagegrille(tab1,couleur);
		writeln('');
		writeln('score : ',score-2);
		repeat
			gettime (h,m,s,c);
			t2:=(h*36000+m*6000+s*100+c);
			deplacement(sens,posx,posy,score,tab1,tab2,victoire);
			if score<>score1 then affichagegrille(tab1,couleur);
			score1:=score;
			sens1:=sens;
		until ((sens1=sens) and (t2-t1>100)) or ((score=score1) and (sens1<>sens));
	until (victoire=false);
	affichagegrille(tab1,couleur);
	writeln('GAME OVER');
	textcolor(green);
	writeln('Score : ',score-2);
	textcolor(black);
	writeln('');
	enregistrementscore(lvl,score);
	writeln('Menu [ ]');
	writeln('Exit [ ]');
	writeln('');
	writeln('Touche ESPACE pour selectioner.');
	pos:=wherey;
	gotoxy(7,pos-4);
	c1:=pos-4;
	InitKeyBoard();
	repeat
		K:=GetKeyEvent();
		K:=TranslateKeyEvent(K);
		if ((KeyEventToString(K) = 'Up') and (wherey>pos-4)) then
			GotoXY(7,wherey-1);
		if ((KeyEventToString(K) = 'Down') and (wherey<pos-3))then
			GotoXY(7,wherey+1);
		c1:=wherey;
	until (KeyEventToString(K) = ' ');
	if c1=pos-3 then retour:=1;
	DoneKeyBoard();
end;


//main program
var tab1:tabt1;
	tab2:tabt2;
	gojeu,goscore,goregles,victoire:boolean;
	retour,score:integer;

BEGIN
	repeat
		clrscr;
		retour:=0;
		score:=2;
		victoire:=true;
		menu(gojeu,goscore,goregles);
		if goscore then affichagescores(retour);
		if goregles then regles(retour);
		if gojeu then jeu(tab1,tab2,score,retour,victoire);
	until retour=1;
end.
