# Construa, lance, execute

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br/), temos “Construa, lance, execute” como quinta boa prática.

Em um processo de automatização de infraestrutura de implantação de software, precisamos ter alguns cuidados para que o comportamento do processo esteja dentro das expectativas e que erros humanos causem baixo impacto no processo completo do desenvolvimento ao lançamento em produção.

![](images/release.png)

Visando organizar, dividir responsabilidade e deixar o processo mais claro, o 12factor indica que o código base para ser colocado em produção deva passar por três fases:

- **Construa** é quando o código do repositório é convertido em um pacote executável. Nesse processo é onde se obtém todas as dependências, compila-se o binário e todos os ativos desse código.
- **Lance** é quando o pacote produzido pela fase de **construir** é combinado com sua configuração. O resultado é o ambiente completo, configurado e pronto para ser colocado em **execução**.
- **Execute** (também como conhecido como “runtime”) é quando um **lançamento** (aplicação + configuração daquele ambiente) é colocado em **execução**, iniciado com base nas configurações especificas do seu ambiente requerido.

Essa boa prática indica que sua aplicação tenha separações explícitas nas fases de **Construa**, **Lance** e **Execute**. Assim cada mudança no código da aplicação é construída apenas uma vez na etapa de **Construa**. Mudanças da configuração não necessitam de uma nova **construção**, sendo apenas necessário passar pelas etapas de **lançar** e **executar**.

Dessa forma é possível criar controles e processos claros em cada etapa, ou seja, caso algo ocorra na **construção** do código, uma medida pode ser tomada e até mesmo abortado o lançamento do mesmo, para que o código em produção não seja comprometido por conta do possível erro.

Com a separação das responsabilidades é possível saber exatamente em qual etapa o problema aconteceu e atuar manualmente caso necessário.

Os artefatos produzidos devem sempre ter um identificador de **lançamento** único, que pode ser o timestamp (como 2011-04-06-20:32:17) ou um número incremental (como v100).

Com o uso de artefato único é possível garantir o uso de uma versão antiga, seja para um plano de retorno ou até mesmo para comparar comportamentos após mudanças no código.

Para atendermos essa boa prática precisamos primeiro construir a imagem Docker com a aplicação dentro, ou seja, ela será nosso artefato.

Teremos um script novo, que aqui chamaremos de build.sh, nesse arquivo teremos o seguinte conteúdo:

```
#!/bin/bash

USER="gomex"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M")

echo "Construindo a imagem ${USER}/app:${TIMESTAMP}"
docker build -t ${USER}/app:${TIMESTAMP} .

echo "Marcando a tag latest também"
docker tag ${USER}/app:${TIMESTAMP} ${USER}/app:latest

echo "Enviando a imagem para nuvem docker"
docker push ${USER}/app:${TIMESTAMP}
docker push ${USER}/app:latest
```

Como podem ver no script acima, além de construir a imagem ele envia a mesma para o [repositório](http://hub.docker.com/) de imagem do docker.

Lembre-se que o código acima e todos os outros dessa boa prática estão [nesse repositório](https://github.com/gomex/exemplo-12factor-docker) na pasta **“factor5“**.

O envio da imagem para o repositório é parte importante da boa prática em questão, pois isso faz com que o processo seja isolado, ou seja, caso a imagem não fosse enviada para um repositório, ela estaria apenas no servidor que executou o processo de **construção** da imagem, sendo assim a próxima etapa precisaria necessariamente ser executada no mesmo servidor, pois ela precisará da imagem disponível.

No modelo proposto a imagem estando no repositório central, ela estará disponível para ser baixada no servidor caso ela não exista localmente. Caso você utilize uma ferramenta de pipeline é importante você ao invés de utilizar a data para tornar o artefato único, utilize variáveis do seu produto para garantir que a imagem que será consumida na etapa de Executar seja a mesma construída no Lançar. Ex. no GoCD temos as variáveis **GO_PIPELINE_NAME** e **GO_PIPELINE_COUNTER** que podem ser usadas em conjunto para garantir isso.

Com a geração da imagem podemos garantir que a etapa **Construir** foi atendida perfeitamente, pois agora temos um artefato construído e pronto para ser reunido a sua configuração.

A etapa de **Lançamento** é o arquivo docker-compose.yml em si, pois o mesmo deve receber as configurações devidas para o ambiente que se deseja colocar a aplicação em questão, sendo assim o arquivo docker-compose.yml muda um pouco e deixará de fazer **construção** da imagem, pois agora ele será utilizado apenas para **Lançamento** e **Execução** (posteriormente):

```
version: "2"
services:
  web:
    image: gomex/app:latest 
    ports:
     - "5000:5000"
    volumes:
     - .:/code
    labels:
     - 'app.environment=${ENV_APP}'
    environment:
     - HOST_RUN=${HOST_RUN}
     - DEBUG=${DEBUG}
     - PORT_REDIS=6379
     - HOST_REDIS=redis
  redis:
    image: redis:3.2.1
    volumes:
     - dados:/data
    labels:
     - 'app.environment=${ENV_APP}'
volumes:
  dados:
    external: false
```

No exemplo **docker-compose.yml** acima usamos a tag latest para garantir que ele usará sempre a ultima imagem **construída** nesse processo, mas como falei anteriormente, caso utilize alguma ferramenta de entrega contínua (Ex. GoCD) faça uso das suas variáveis para garantir o uso da imagem criada naquela execução específica do pipeline.

Dessa forma, **lançamento** e **execução** sempre utilizarão o mesmo artefato, a imagem Docker, construída na fase de construção..

E etapa de **execução** basicamente é executar o docker-compose com o comando abaixo:

```
docker-compose up -d
```