#!/bin/bash

SIM="$HOME/simulacao" #define path padrao pro projeto, /tmp é irreal

# as chaves de cada nó ficam em cada nó!!
mkdir -p "$SIM/A/chaves" # cria diretorios para os 3 peers
mkdir -p "$SIM/B/chaves" # -p -> apenas se nao existirem
mkdir -p "$SIM/C/chaves" 

if [ ! -f "$SIM/A/chaves/adama" ]; then # cria chaves novas apenas se nao existirem
    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/A/chaves/adama
    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/A/chaves/roslin
    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/A/chaves/asimov # 3 no peer A

    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/B/chaves/kirk
    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/B/chaves/spock # 2 no peer B

    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/C/chaves/paul
    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/C/chaves/anakin
    ssh-keygen -t ed25519 -N '' -C '' -f $SIM/C/chaves/avasarala # 3 no peer C
fi 

eval $(luarocks --lua-version=5.4 path --bin) # configura o caminho para o luarocks funcionar
freechains --version # testa se o freechains esta ok e na versao certa

mkdir -p "$SIM/A/chains" # cria as pastas base /chains para o daemon iniciar
mkdir -p "$SIM/B/chains"
mkdir -p "$SIM/C/chains"
mkdir -p "$SIM/HUB/chains"

freechains --root="$SIM/A/" daemon start --port=8331 & # inicia os 3 peers no background (&)
freechains --root="$SIM/B/" daemon start --port=8332 & # e define os diretorios de cada um
freechains --root="$SIM/C/" daemon start --port=8333 &
freechains --root="$SIM/HUB/" daemon start --port=8330 --hub & # hub para facilitar sync

TEMPO=$(date +%s) # salva o tempo de criacao!!

# !! adama cria a chain #videos 
freechains --now="$TEMPO" --root="$SIM/A/" chains add '#videos' init --pioneer="$SIM/A/chaves/adama.pub"

HUB="localhost:8330" # para facilitar a sincronização
A="localhost:8331"
B="localhost:8332"
C="localhost:8333"

freechains --now="$TEMPO" --root="$SIM/HUB/" chains add '#videos' clone $A # hub clona de A
freechains --now="$TEMPO" --root="$SIM/B/" chains add '#videos' clone $HUB # B clona de hub
freechains --now="$TEMPO" --root="$SIM/C/" chains add '#videos' clone $HUB # C clona de hub

# fazer SIM="$HOME/simulacao" no terminal individual, para rodar sem o script, é necessario!!

sleep 2 # espera um tempo para os daemons iniciarem

#------------------------------------------------------------------------

# --- [01/01] ---

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama faz o primeiro post da cadeia
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# roslin faz um beg para entrar, salvo em var para like dinâmico
BEG_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/A/chaves/roslin")

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama dá um like e aceita roslin na chain
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 5000 action "$BEG_ROSLIN" --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [02/01] ---

# adama faz outro post -- ALTERAR CONTEUDO!!!!!!!!!!!!!!!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

TEMPO=$((TEMPO + 3600)) # avança 1 hora

#roslin dá um like no post de adama
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 200 action "$POST_ADAMA" --sign="$SIM/A/chaves/roslin" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [03/01] ---

# asimov faz um beg para entrar -- ALTERAR CONTEUDO!!!!!!!!!!!!!
BEG_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/A/chaves/asimov")

TEMPO=$((TEMPO + 7200)) # avança 2 horas

# adama dá um like e aceita asimov na chain
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 5000 action "$BEG_ASIMOV" --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# asimov faz um post -- ALTERAR CONTEUDO!!!!!!!!!!!!!!!!!!
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [04/01] ---

# adama faz um post -- ALTERAR CONTEUDO!!!!!!!!!!
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama"

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [05/01] ---

# asimov faz um post -- ALTERAR CONTEUDO!!!!!!!
POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov") 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama dá um like considerável no post de asimov
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 8000 action "$POST_ASIMOV" --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [06/01] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [07/01] ---

# adama faz um post -- ALTERAR CONTEUDO!!!!!!!!!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# asimov dá um dislike no post de adama, pois o link está quebrado
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' dislike 500 action "$POST_ADAMA" --sign="$SIM/A/chaves/asimov" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [08/01] ---

# roslin faz um post -- ALTERAR CONTEUDO !!!!!!!!!!!!
POST_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/roslin")

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [09/01] ---

# asimov faz um post -- ALTERAR CONTEUDO!!!!!!!!!
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov"

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [10/01] ---

#asimov faz um post -- ALTERAR CONTEUDO
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov"

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [11/01] ---

#adama faz um post -- ALTERAR CONTEUDO!!
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama"

# asimov dá um like no post de roslin
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 500 action "$POST_ROSLIN" --sign="$SIM/A/chaves/asimov" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [12/01] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [13/01] ---

#asimov faz um post -- ALTERAR CONTEUDO
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov"

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [14/01] ---

# roslin faz um post -- ALTERAR CONTEUDO !!!!!!!!!!!!
POST_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/roslin")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama dá um like no post de roslin
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 8000 action "$POST_ROSLIN" --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [15/01] ---

#asimov faz um post -- ALTERAR CONTEUDO
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov"
TEMPO=$((TEMPO + 3600)) # avança 1 hora

#adama faz um post -- ALTERAR CONTEUDO!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [16/01] ---

# asimov dá um like no post de adama
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 500 action "$POST_ADAMA" --sign="$SIM/A/chaves/asimov" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [17/01] ---

#adama faz um post -- ALTERAR CONTEUDO!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# roslin dá um like no post de adama
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 500 action "$POST_ADAMA" --sign="$SIM/A/chaves/roslin" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [18/01] ---

# peer B entra na rede --------------------------BBBBB-------------------------------

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A # hub puxa de A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB # B puxa de hub

# kirk faz um beg para entrar, salvo em var para like dinâmico
BEG_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/B/chaves/kirk")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B # hub puxa de B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB # A puxa de hub

# asimov dá um like no beg de kirk
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 2000 action "$BEG_KIRK" --sign="$SIM/A/chaves/asimov" 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A # hub puxa de A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB # B puxa de hub

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [19/01] ---

#adama faz um post -- ALTERAR CONTEUDO!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [20/01] ---

#kirk faz um post -- ALTERAR CONTEUDO!!
POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

# adama dá um like no post de kirk
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 500 action "$POST_KIRK" --sign="$SIM/A/chaves/adama" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [21/01] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [22/01] ---

#kirk faz um post -- ALTERAR CONTEUDO!!
POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

#asimov faz um post -- ALTERAR CONTEUDO!!
POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

# kirk dá um like no post de asimov
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' like 500 action "$POST_ASIMOV" --sign="$SIM/B/chaves/kirk" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [23/01] ---

# roslin faz um post -- ALTERAR CONTEUDO !!!!!!!!!!!!
POST_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/roslin")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [24/01] ---

#kirk faz um post -- ALTERAR CONTEUDO!!
POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

#adama faz um post -- ALTERAR CONTEUDO!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [25/01] ---

#adama faz um post -- ALTERAR CONTEUDO!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

# adama dá dislike no post de roslin, pois o link está quebrado
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' dislike 500 action "$POST_ROSLIN" --sign="$SIM/A/chaves/adama" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [26/01] ---

#kirk faz um post -- ALTERAR CONTEUDO!!
POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [27/01] ---

# spock faz um beg para entrar, salvo em var para like dinâmico
BEG_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/B/chaves/spock")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

# kirk dá um like no beg de spock
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' like 1000 action "$BEG_SPOCK" --sign="$SIM/B/chaves/kirk" 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [28/01] ---

#asimov faz um post -- ALTERAR CONTEUDO!!
POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

# spock faz um post -- ALTERAR CONTEUDO!!
POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [29/01] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [30/01] ---

# roslin faz um post -- ALTERAR CONTEUDO!!
POST_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/roslin")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# roslin dá um like no post de spock
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 1000 action "$POST_SPOCK" --sign="$SIM/A/chaves/roslin" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [01/02] ---

# kirk faz um post -- ALTERAR CONTEUDO!!
POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama dá um dislike no post de kirk, que está quebrado
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' dislike 500 action "$POST_KIRK" --sign="$SIM/A/chaves/adama" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [02/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [03/02] ---

# peer C entra na rede --------------------------CCCCCC----------------------------

# paul faz um beg para entrar, salvo em var para like dinâmico
BEG_PAUL=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/C/chaves/paul")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

# adama desconhece paul, mas como seu conteúdo parecia legítimo, o deixou entrar
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 1000 action "$BEG_PAUL" --sign="$SIM/A/chaves/adama" 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [04/02] ---

# paul faz um post malicioso -- ALTERAR CONTEUDO!!
POST_PAUL=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/C/chaves/paul")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

#adama dá um revoke pesado no post malicioso de paul
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' revoke 1500 action "$POST_PAUL" --sign="$SIM/A/chaves/adama" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [05/02] ---

# asimov faz um post -- ALTERAR CONTEUDO!!
POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [06/02] ---

# spock faz um post -- ALTERAR CONTEUDO!!
POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

#adama dá um like no post de spock
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 500 action "$POST_SPOCK" --sign="$SIM/A/chaves/adama" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [07/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [08/02] ---

# anakin faz um beg para entrar, salvo em var para like dinâmico
BEG_ANAKIN=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/C/chaves/anakin")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

# roslin dá um like no beg de anakin
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 1000 action "$BEG_ANAKIN" --sign="$SIM/A/chaves/roslin" 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [09/02] ---

# anakin faz um post -- ALTERAR CONTEUDO!!!
POST_ANAKIN=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/C/chaves/anakin")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [10/02] ---

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [11/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [12/02] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 3600)) # avança 1 hora
POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [13/02] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 3600)) # avança 1 hora
# adama dá like no post de kirk
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 1000 action "$POST_KIRK" --sign="$SIM/A/chaves/adama" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [14/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [15/02] ---

#kirk da like no post de asimov
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' like 1000 action "$POST_ASIMOV" --sign="$SIM/B/chaves/kirk" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [16/02] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [17/02] ---

POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [18/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [19/02] ---

POST_ANAKIN=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/C/chaves/anakin")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 3600)) # avança 1 hora
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [20/02] ---

POST_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/roslin")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

#kirk da like no post de roslin
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' like 500 action "$POST_ROSLIN" --sign="$SIM/B/chaves/kirk" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [21/02] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [22/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [23/02] ---

POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [24/02] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [25/02] ---

POST_ANAKIN=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/C/chaves/anakin")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [26/02] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# asimov dá um dislike no post de kirk, pois o link está quebrado
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' dislike 500 action "$POST_KIRK" --sign="$SIM/A/chaves/asimov" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [27/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [28/02] ---

# POST MALICIOSO DE ANAKIN
POST_ANAKIN=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/C/chaves/anakin")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 3600)) # avança 1 hora

#adama dá um revoke pesado no post malicioso de anakin
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' revoke 1500 action "$POST_ANAKIN" --sign="$SIM/A/chaves/adama" 

#roslin dá um revoke pesado no post malicioso de anakin
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' revoke 2000 action "$POST_ANAKIN" --sign="$SIM/A/chaves/roslin" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [29/02] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [30/02] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [01/03] ---

POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [02/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [03/03] ---

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [04/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [05/03] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [06/03] ---

POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# asimov dá um like no post de spock
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 500 action "$POST_SPOCK" --sign="$SIM/A/chaves/asimov" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [07/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [08/03] ---

# avasarala faz um beg para entrar, salvo em var para like dinâmico
BEG_AVASARALA=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/C/chaves/avasarala")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

# adama dá um like no beg de avasarala
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' like 1000 action "$BEG_AVASARALA" --sign="$SIM/A/chaves/adama" 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [09/03] ---

POST_AVASARALA=$(freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/C/chaves/avasarala")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $C
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [10/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [11/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [12/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [13/03] ---

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [14/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [15/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [16/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [17/03] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [18/03] ---

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [19/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [20/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [21/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [22/03] ---

POST_SPOCK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/spock")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 


TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [23/03] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# kirk dá um like no piost de spock
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' like 1000 action "$POST_SPOCK" --sign="$SIM/B/chaves/kirk" 

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [24/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [25/03] ---

POST_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/asimov")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [26/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [27/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [28/03] ---

POST_KIRK=$(freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/B/chaves/kirk")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $B
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
TEMPO=$((TEMPO + 3600)) # avança 1 hora

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [29/03] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [30/03] ---

POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

freechains --now="$TEMPO" --root="$SIM/HUB/" chain '#videos' sync recv $A
freechains --now="$TEMPO" --root="$SIM/C/" chain '#videos' sync recv $HUB 
freechains --now="$TEMPO" --root="$SIM/B/" chain '#videos' sync recv $HUB 

echo "final!!!"

# TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# TEMPO=$((TEMPO + 43200)) # avança 12 horas
# TEMPO=$((TEMPO + 3600)) # avança 1 hora





# fechar os programas e as portas
#pkill -9 freechains
#pkill -9 git-daemon
# remove a pasta das chains, para testes apenas!
#rm -rf "$SIM/A/chains" "$SIM/B/chains" "$SIM/C/chains" "$SIM/HUB/chains"  