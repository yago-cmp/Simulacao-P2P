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

freechains --root="$SIM/A/" daemon start --port=8330 --hub & # inicia os 3 peers no background (&)
freechains --root="$SIM/B/" daemon start --port=8331 --hub & # e define os diretorios de cada um
freechains --root="$SIM/C/" daemon start --port=8332 --hub &

# fazer SIM="$HOME/simulacao" no terminal individual, para rodar sem o script, é necessario!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

sleep 3 # espera um tempo para eles iniciarem

# !! adama cria a chain #videos ------------------------------------------------------------------------
freechains --root="$SIM/A/" chains add '#videos' init --pioneer="$SIM/A/chaves/adama.pub"
TEMPO=$(date +%s) # salva o tempo de criacao!!
# --- [01/01] ---

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama faz o primeiro post da cadeia
freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# roslin faz um beg para entrar, salvo em var para like dinâmico
BEG_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/A/chaves/roslin")

TEMPO=$((TEMPO + 3600)) # avança 1 hora

# adama dá um like e aceita roslin na chain
freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' like 5000 action "$BEG_ROSLIN" --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [02/01] ---

# adama faz outro post -- ALTERAR CONTEUDO!!!!!!!!!!!!!!!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")

TEMPO=$((TEMPO + 3600)) # avança 1 hora

#roslin dá um like no post de adama
freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' like 200 action "$POST_ADAMA" --sign="$SIM/A/chaves/roslin" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [03/01] ---

# asimov faz um beg para entrar -- ALTERAR CONTEUDO!!!!!!!!!!!!!
BEG_ASIMOV=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/A/chaves/asimov")

TEMPO=$((TEMPO + 7200)) # avança 2 horas

# adama dá um like e aceita asimov na chain
freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' like 5000 action "$BEG_ASIMOV" --sign="$SIM/A/chaves/adama" 

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
freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' like 8000 action "$POST_ASIMOV" --sign="$SIM/A/chaves/adama" 

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [06/01] ---

# hoje, nada acontece!

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
# --- [07/01] ---

# adama faz um post -- ALTERAR CONTEUDO!!!!!!!!!!
POST_ADAMA=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama")
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# asimov dá um dislike no post de adama, pois o link está quebrado
freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' dislike 500 action "$POST_ADAMA" --sign="$SIM/A/chaves/asimov" 

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

# asimov dá um dislike no post de adama, pois o link está quebrado
freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' dislike 500 action "$POST_ADAMA" --sign="$SIM/A/chaves/asimov" 

# --- [18/01] ---
freechains --now="$TEMPO" --root="$SIM/B/" chains add '#videos' clone localhost:8330 # peer B inicia a chain localmente

# --- [02/03] ---
freechains --now="$TEMPO" --root="$SIM/C/" chains add '#videos' clone localhost:8330 # peer C inicia a chain localmente




TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados
TEMPO=$((TEMPO + 43200)) # avança 12 horas
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# fecha os programas e as portas
#pkill -9 freechains
#pkill -9 git-daemon

echo "tudo certo ate aqui!"
# remove a pasta das chains, para testes apenas!
#rm -rf "$SIM/A/chains" "$SIM/B/chains" "$SIM/C/chains" 