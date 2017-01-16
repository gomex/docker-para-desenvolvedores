# Criando sua própria imagem no Docker


Antes de explicarmos como criar sua imagem, vale a pena tocarmos em uma questão que normalmente confunde iniciantes do docker: “Imagem ou container?”

### Qual diferença de Imagem e Container?

Fazendo um paralelo com o conceito de [orientação a objeto](https://pt.wikipedia.org/wiki/Orienta%C3%A7%C3%A3o_a_objetos), a **imagem** é a classe e o **container** o objeto, ou seja, a imagem é a abstração da infraestrutura em um estado somente leitura, que é de onde será instanciado o container.

Todo container é iniciado a partir de uma imagem, dessa forma podemos concluir que nunca teremos uma imagem em execução.

Um container só pode ser iniciado a partir de uma única imagem, ou seja,  caso deseje um comportamento diferente será necessário customizar a imagem.

### Anatomia de uma imagem

As imagens podem ser oficial ou não oficial.

#### Imagens oficiais e não oficiais

As imagens oficiais da docker são aquelas que não tem usuário em seu nome, ou seja, a imagem **“ubuntu:16.04″** é oficial, por outro lado a imagem [“nuagebec/ubuntu”](https://hub.docker.com/r/nuagebec/ubuntu/) não é oficial. Essa segunda imagem é mantida pelo usuário [nuagebec](https://hub.docker.com/u/nuagebec/), que mantém muitas outras imagens não oficiais.

As imagens oficiais são mantidas pela empresa docker e são [disponibilizadas](https://hub.docker.com/explore/) na nuvem docker.

O objetivo das imagens oficiais é prover um ambiente básico (ex. debian, alpine, ruby, python) que serve de ponto de partida para criação de imagens pelos usuários, que é o que explicaremos mais adiante ainda nesse capítulo.

As imagens não oficiais são mantidas pelos usuários que as criaram. Falaremos sobre envio de imagens para nuvem docker em outro tópico.

**Nome da imagem**

O nome de uma imagem oficial é composta de duas partes. A primeira é o que a [documentação](https://docs.docker.com/engine/userguide/containers/dockerimages/) chama de **“repositório”** e a segunda é a **“tag”**. No caso da imagem **“ubuntu:14.04”**, **ubuntu** é o repositório e **14.04** é a tag.

Para o docker o **“repositório”** é uma abstração de conjunto de imagens, ou seja, não confunda com o local de armazenamento das imagens, que detalharemos mais a frente.

Para o docker a **“tag”** é uma abstração para criar uma unidade dentro do conjunto de imagens definidas no **“repositório”**.

Um **“repositório”** pode conter mais de uma **“tag”** e cada conjunto repositório:tag representa uma imagem diferente.

Execute [esse comando](https://docs.docker.com/engine/reference/commandline/images/) abaixo para visualizar todas as imagens que se encontram localmente na sua estação nesse momento:

```
docker images
```

### Como se cria imagens

Há duas formas de criar imagens customizadas: Com **commit** e com **Dockerfile**.

#### Criando imagens com commit

É possível criar imagens executando o comando [commit](https://docs.docker.com/engine/reference/commandline/commit/) relacionado a um container, ou seja, esse comando pegará o status atual desse container escolhido e criará uma imagem com base nele.

Vamos ao exemplo. Primeiro vamos criar um container qualquer:

```
docker run -it --name containercriado ubuntu:16.04 bash
```

Agora que estamos no bash do container, vamos instalar o nginx nele:

```
apt-get update
apt-get install nginx -y
exit
```

Vamos parar o container com o comando abaixo:

```
docker stop containercriado
```

Agora vamos efetuar o **commit** desse **container** em uma **imagem**:

```
docker commit containercriado meuubuntu:nginx
```

No exemplo do comando acima, **containercriado** é o nome do container que criamos e modificamos nos passos anteriores e o nome **meuubuntu:nginx** é a imagem resultante do **commit**, ou seja, o estado do **containercriado** será armazenado em uma imagem chamada **meuubuntu:nginx** que nesse caso a única modificação que temos da imagem oficial do ubuntu na versão 16.04 é um pacote **nginx** instalado.

Para visualizar a lista de imagens e encontrar a que acabou de criar, execute novamente o comando abaixo:

```
docker images
```

Para testar sua nova imagem, vamos criar um container a partir dela e verificar se o nginx está instalado:

```
docker run -it --rm meuubuntu:nginx dpkg -l nginx
```

Se quiser validar, pode executar o mesmo comando na imagem oficial do ubuntu:

```
docker run -it --rm ubuntu:16.04 dpkg -l nginx
```

> Vale salientar que o método **commit** não é a melhor opção para criar imagens, pois como pudemos verificar, o processo de modificação da imagem é completamente manual e apresenta certa dificuldade para rastrear as mudanças que foram efetuadas, uma vez que o que foi modificado manualmente não é registrado automaticamente na estrutura do docker.

#### Criando imagens com Dockerfile

Quando se utiliza Dockerfile para gerar uma imagem, basicamente é apresentado uma lista de instruções que serão aplicadas em uma determinada imagem para que outra seja gerada com base nessas modificações.

![Dockerfile](images/dockerfile.png)

Podemos resumir que o arquivo Dockerfile na verdade representa a exata diferença entre uma determinada imagem, que aqui chamamos de **base**, e a imagem que se deseja criar, ou seja, nesse modelo temos total rastreabilidade sobre o que será modificado nessa nova imagem.

Vamos ao mesmo exemplo da instalação do nginx no ubuntu 16.04.

Primeiro crie um arquivo qualquer para um teste futuro:

```
touch arquivo_teste
```

Crie um arquivo chamado **Dockerfile** e dentro dele coloque o seguinte conteúdo:

```
FROM ubuntu:16.04
RUN apt-get update && apt-get install nginx -y
COPY arquivo_teste /tmp/arquivo_teste
CMD bash
```

No arquivo acima eu utilizei quatro [instruções](https://docs.docker.com/engine/reference/builder/):

**FROM** é usado para informar qual imagem usarei como base, que nesse caso foi a **ubuntu:16.04**.

**RUN** é usado para informar quais comandos serão executados nesse ambiente para efetuar as mudanças necessárias na infraestrutura do sistema. São como comandos executados no shell do ambiente, igual ao modelo por commit, mas nesse caso foi efetuado automaticamente e completamente rastreável, já que esse Dockerfile será armazenado no sistema de controle de versão.

**COPY** é usado para copiar arquivos da estação onde está executando a construção para dentro da imagem. Usamos um arquivo de teste apenas para exemplificar essa possibilidade, mas essa instrução é muito utilizada para enviar arquivos de configuração de ambiente e códigos para serem executados em serviços de aplicação.

**CMD** é usado para informar qual comando será executado por padrão, caso nenhum seja informado na inicialização de um container a partir dessa imagem. No nosso caso colocamos o comando bash, ou seja, caso essa imagem seja usada para iniciar um container e não informamos o comando, ele executará o bash.

Após construir seu Dockerfile basta executar o [comando](https://docs.docker.com/engine/reference/commandline/build/) abaixo:

```
docker build -t meuubuntu:nginx_auto .
```

O comando acima tem a opção **“-t”** que serve para informar o nome da imagem que será criada, que no nosso caso será **meuubuntu:nginx_auto** e o **“.”** no final informa qual o contexto que deve ser usado nessa construção de imagem, ou seja, todos os arquivos da sua pasta atual serão enviados para o serviço do docker e apenas eles podem ser usados para manipulações do Dockerfile (Exemplo do uso do COPY).

#### A ordem importa

É importante atentar que o arquivo **Dockerfile** é uma sequência de instruções que é lido do topo até sua base e cada linha é executada por vez, ou seja, caso alguma instrução dependa de uma outra instrução, essa dependência deve vir mais acima no documento.

O resultado de  cada instrução desse arquivo é armazenado em um cache local, ou seja, caso o **Dockerfile** não seja modificado na próxima criação da imagem (**build**) o processo não demorará, pois tudo estará no cache, mas caso algo seja modificado apenas a instrução modificada e as posteriores serão executadas novamente.

A sugestão pra aproveitar bem o cache do **Dockerfile** é sempre manter instruções que mudem com mais frequência mais próximas da base do documento. Vale lembrar de atender também as dependências entre instruções.

Vamos utilizar um exemplo pra deixar mais claro:

```
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install nginx
RUN apt-get install php5
COPY arquivo_teste /tmp/arquivo_teste
CMD bash
```

Caso modifiquemos a terceira linha do arquivo e ao invés de instalar o nginx mudarmos para apache2, a instrução que faz o update no apt não será executada novamente, mas a instalação do apache2 será instalado, pois acabou de entrar no arquivo, assim como o php5 e a cópia do arquivo, pois todos eles são subsequentes a linha modificada.

Como podemos perceber, com posse do arquivo **Dockerfile**, é possível ter noção exata de quais mudanças foram efetuadas na imagem e assim registrar as modificações no seu sistema de controle de versão.

### Enviando sua imagem para nuvem

[Capítulo anterior: Comandos básicos](comandos.md) | [Próximo capítulo: Entendendo armazenamento no Docker](armazenamento.md)