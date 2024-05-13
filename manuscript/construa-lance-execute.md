# Construa, lance, execute

O próximo item da lista do modelo [12factor](https://12factor.net/pt_br/), “Construa, lance, execute” é a quinta boa prática..

No processo de automatização de infraestrutura de implantação de software precisamos cuidado para que o comportamento do processo esteja dentro das expectativas e erros humanos causem baixo impacto no processo completo do desenvolvimento, do lançamento à produção.

![](images/release.png)

Visando organizar, dividir responsabilidade e tornar o processo mais claro, o 12factor indica que o código base, para ser colocado em produção, deva passar por três fases:

- **Construa** - converter código do repositório em pacote executável. Nesse processo se obtém as dependências, compila-se o binário e os ativos do código.
- **Lance** - pacote produzido na fase **construir** é combinado com a configuração. O resultado é o ambiente completo, configurado e pronto para ser colocado em **execução**.
- **Execute** (também conhecido como “runtime”) - inicia a **execução** do **lançamento** (aplicação + configuração daquele ambiente) com base nas configurações específicas do ambiente requerido.

A boa prática indica que a aplicação tenha separações explícitas nas fases de **Construa**, **Lance** e **Execute**. Assim, cada mudança no código da aplicação é construída apenas uma vez na etapa de **Construa**. Mudanças da configuração não necessitam nova **construção** sendo necessário, apenas, as etapas de **lançar** e **executar**.

De tal forma é possível criar controles e processos claros em cada etapa. Caso algo ocorra na **construção** do código, uma medida pode ser tomada ou mesmo se cancela o lançamento para que o código em produção não seja comprometido por conta do possível erro.

Com a separação das responsabilidades é possível saber em qual etapa o problema aconteceu e atuar manualmente, caso necessário.

Os artefatos produzidos devem ter um identificador de **lançamento** único. Pode ser o timestamp (como 2011-04-06-20:32:17) ou um número incremental (como v100). Com o artefato único é possível garantir o uso de versão antiga, seja para plano de retorno ou, até mesmo, para comparar comportamentos após mudanças no código.

Para atendermos a boa prática precisamos construir a imagem Docker com a aplicação dentro. Ela será nosso artefato.

Teremos um script novo, aqui chamado build.sh, com o seguinte conteúdo:

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

Além de construir a imagem a envia para o [repositório](https://hub.docker.com/) de imagem do Docker.

Lembre-se que o código acima e os demais da boa prática estão [no repositório](https://github.com/gomex/exemplo-12factor-docker) na pasta **“factor5“**.

O envio da imagem para o repositório é parte importante da boa prática em questão, pois isola o processo. Caso a imagem não seja enviada para o repositório permanece apenas no servidor que executou o processo de **construção**. Sendo assim a próxima etapa precisa, necessariamente, ser executada no mesmo servidor, pois nela precisaremos da imagem disponível.

No modelo proposto a imagem do repositório central fica disponível para ser baixada no servidor. Caso utilize uma ferramenta de pipeline é importante - ao invés de utilizar a data para tornar o artefato único - usar variáveis do produto para garantir que a imagem a ser consumida na etapa Executar seja a mesma construída na etapa Lançar. Exemplo no GoCD: variáveis **GO_PIPELINE_NAME** e **GO_PIPELINE_COUNTER** podem ser usadas em conjunto como garantia.

Com a geração da imagem podemos garantir que a etapa **Construir** foi atendida perfeitamente porque agora temos um artefato construído e pronto para ser reunido à configuração.

A etapa de **Lançamento** é o arquivo docker-compose.yml em si, pois o mesmo recebe as configurações devidas para o ambiente no qual se deseja hospedar a aplicação. Sendo assim, o arquivo docker-compose.yml muda um pouco e deixa de fazer a **construção** da imagem, já que, agora, será utilizado apenas para **Lançamento** e **Execução** (posteriormente):

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

No exemplo **docker-compose.yml**, acima, usamos a tag latest para garantir que busque sempre a última imagem **construída** no processo. Mas como já mencionamos, caso utilize alguma ferramenta de entrega contínua (como GoCD, por exemplo) faça uso das variáveis para garantir a imagem criada na execução específica do pipeline.

Dessa forma, **lançamento** e **execução** utilizarão o mesmo artefato: a imagem Docker construída na fase de construção.

A etapa de **execução**, basicamente, executa o Docker-Compose com o comando abaixo:

```
docker-compose up -d
```
