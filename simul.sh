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

freechains --root="$SIM/A/" daemon start --port=8330 & # inicia os 3 peers no background (&)
freechains --root="$SIM/B/" daemon start --port=8331 & # e define os diretorios de cada um
freechains --root="$SIM/C/" daemon start --port=8332 &

# fazer SIM="$HOME/simulacao" no terminal individual, para rodar sem o script, é necessario!!

sleep 3 # espera um tempo para eles iniciarem

# !! adama cria a chain #videos
freechains --root="$SIM/A/" chains add '#videos' init --pioneer="$SIM/A/chaves/adama.pub"
TEMPO=$(date +%s) # salva o tempo de criacao!!

TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Gatinhos muito fofos brincando", "tags": ["gatos", "filhotes", "engraçado", "animais", "pets", "meow"], "link": "www.youtube.com/watch?v=catmock001"}' --sign="$SIM/A/chaves/adama"
# adama faz o primeiro post da cadeia

TEMPO=$((TEMPO + 3600)) # avança 1 hora

BEG_ROSLIN=$(freechains --now="$TEMPO" --root="$SIM/A/" chain '#videos' post inline $'{"titulo": "Compilação de miados engraçados", "tags": ["gatos", "miado", "fofos", "brincadeira", "felinos", "comedia"], "link": "www.vimeo.com/catmock002"}' --beg --sign="$SIM/A/chaves/roslin")
# roslin faz um beg para entrar, salvo em var para like dinâmico

TEMPO=$((TEMPO + 3600)) # avança 1 hora

freechains --now="$TEMPO" chain --root="$SIM/A/" '#videos' like 5000 action "$BEG_ROSLIN" --sign="$SIM/A/chaves/adama"
# adama dá um like e aceita roslin na chain

TEMPO=$((TEMPO + 86400)) # avança 24 horas, os posts se consolidam, reps recuperados

TEMPO=$((TEMPO + 43200)) # avança 12 horas
TEMPO=$((TEMPO + 3600)) # avança 1 hora

# fecha os programas e as portas
#pkill -9 freechains
#pkill -9 git-daemon

echo "tudo certo ate aqui!"
# remove a pasta das chains, para testes apenas!
#rm -rf "$SIM/A/chains" "$SIM/B/chains" "$SIM/C/chains" 