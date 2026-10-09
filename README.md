# Simulação Freechains

## Propósito
O propósito da simulação é ilustrar o funcionamento do Freechains por um período de **3 meses**, já condicionando e contextualizando com a minha aplicação final da disciplina de **Sistemas Peer-to-Peer**, da UERJ.

O protocolo será utilizado da forma como a aplicação **Link Chains** a usaria, com **mensagens padronizadas contendo links** de conteúdo (Nesse caso da simulação, **links mockados** ou do Youtube, por exemplo). 

Teremos **diversos pares** e diversos usuários por par. A ideia é fazer o uso intensivo de **likes**, **dislikes**, **revokes** e **begs** para criar um perfil para cada tipo de usuário, e ver como eles se comportariam em um uso real da aplicação.

## Personagens
Cada um dos usuários a seguir interpretam um tipo, um arquétipo de personagem. O objetivo é ilustrar como usuários de diferentes personalidades, índoles e propósitos na rede interagem entre si e como ela como um todo reage a essa situação. A chain criada se chama `#videos`.

Abaixo estão relacionados os usuários, sua data de ingresso e seu perfil geral (como eles se comportam na rede).

| Nome               | Data  | Comportamento            |
| ------------------ | ----- | ------------------------ |
| Almirante Adama    | 01/01 | **Pioneiro**, Hard User  |
| Presidente Roslin  | 01/01 | Soft User                |
| Isaac Asimov       | 03/01 | Hard User                |
| James Kirk         | 18/01 | Regular, Generoso        |
| Spock              | 27/01 | Regular, Avarento        |
| Padre Paul         | 03/02 | **Malicioso**, Enganador |
| Anakin Skywalker   | 08/02 | Volátil, **Malicioso**   |
| Chrisjen Avasarala | 06/03 | Free Rider               |

Adama criou a `#videos` no dia 01/01. Sua amiga Roslin entrou logo depois, no mesmo dia. Os dois chamaram para a rede seu amigo Asimov. Kirk é amigo de longa data de Asimov, e foi por ele indicado para entrar na rede. Spock, a contragosto, entrou na rede a pedido de Kirk, para que ele possa compartilhar seus vídeos. Com inveja do sucesso da rede, Paul tentou posar como um usuário legítimo e fez um beg, mas pouco tempo depois, teve seus posts revogados por espalhar spam. Anakin era conhecido por todos, e por uma ação de graça, Roslin o aceitou na rede. Anakin nunca foi muito confiável, e depois de um certo tempo passou a compartilhar links para conteúdos maliciosos. Avasarala é louca por assistir vídeos de gatos, mas ela em si não é muito chegada a compartilhar sua coleção pessoal. Ela entrou na rede fazendo um beg com um de seus favoritos, depois de muita incerteza se devia compartilhá-lo ou não.

## Reps

O uso dos reps é baseado no que ficou definido no Link Chains: Um like é uma gorjeta, opcional, para quando o conteúdo é considerado bom ou raro. Um dislike é uma sinalização de que o link para o conteúdo está quebrado. Um revoke é uma denúncia, uma punição que remove o conteúdo postado da rede para moderação contra spam ou conteúdo malicioso. Em diversos momentos da simulação, houveram links quebrados e sinalizados com dislikes, além de posts maliciosos de Anakin e Paul, que foram devidamente punidos com denúncias (revokes). Volta e meia também era proferido um like, que serviu como incentivo para que os usuários continuem postando. 

## Resultado

A simulação funcionou como esperado. Tive alguma dificuldade com relação aos Daemons, mas no fim tudo deu certo. Os usuários ficcionais representaram de forma razoável arquétipos de pessoas reais utilizando a rede, e foi estabelecido um padrão de sincronização que pode ser facilmente reproduzido na aplicação final da disciplina.