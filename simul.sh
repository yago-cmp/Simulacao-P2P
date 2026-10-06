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

mkdir -p "$SIM/A/chaves" "$SIM/A/chains" # cria as pastas base /chains para o daemon iniciar
mkdir -p "$SIM/B/chaves" "$SIM/B/chains"
mkdir -p "$SIM/C/chaves" "$SIM/C/chains"

freechains --root="$SIM/A/" daemon start --port=8330 & # inicia os 3 peers no background (&)
freechains --root="$SIM/B/" daemon start --port=8331 & # e define os diretorios de cada um
freechains --root="$SIM/C/" daemon start --port=8332 &
# usei 'pkill -9 git-daemon' para fechar todas as instancias, depois
# fazer SIM="$HOME/simulacao" no terminal individual, para rodar sem o script, é necessario

sleep 4 # espera um tempo para eles iniciarem

# !! criacao da chain #videos pelo adama
freechains --root="$SIM/A/" chains add '#videos' init --pioneer="$SIM/A/chaves/adama.pub"


