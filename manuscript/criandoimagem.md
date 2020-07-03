# Criando sua própria imagem no Docker


Antes de explicarmos como criar sua imagem, vale a pena tocarmos em uma questão que normalmente confunde iniciantes do docker: “Imagem ou contêiner?”

### Qual a diferença entre Imagem e Contêiner?

Traçando um paralelo com o conceito de [orientação a objeto](https://pt.wikipedia.org/wiki/Orienta%C3%A7%C3%A3o_a_objetos), a **imagem** é a classe e o **contêiner** o objeto. A imagem é a abstração da infraestrutura em estado somente leitura, de onde será instanciado o contêiner.

Todo contêiner é iniciado a partir de uma imagem, dessa forma podemos concluir que nunca teremos uma imagem em execução.

Um contêiner só pode ser iniciado a partir de uma única imagem. Caso deseje um comportamento diferente, será necessário customizar a imagem.

### Anatomia da imagem

As imagens podem ser oficiais ou não oficiais.

#### Imagens oficiais e não oficiais

As imagens oficiais do docker são aquelas sem usuários em seus nomes. A imagem **“ubuntu:16.04″** é oficial, por outro lado, a imagem [“nuagebec/ubuntu”](https://hub.docker.com/r/nuagebec/ubuntu/) não é oficial. Essa segunda imagem é mantida pelo usuário [nuagebec](https://hub.docker.com/u/nuagebec/), que mantém outras imagens não oficiais.

As imagens oficiais são mantidas pela empresa docker e [disponibilizadas](https://hub.docker.com/explore/) na nuvem docker.

O objetivo das imagens oficiais é prover um ambiente básico (ex. debian, alpine, ruby, python), um ponto de partida para criação de imagens pelos usuários, como explicaremos mais adiante, ainda nesse capítulo.

As imagens não oficiais são mantidas pelos usuários que as criaram. Falaremos sobre envio de imagens para nuvem docker em outro tópico.

**Nome da imagem**

O nome de uma imagem oficial é composto por duas partes. A primeira, a [documentação](https://docs.docker.com/engine/userguide/containers/dockerimages/) chama de **“repositório”** e, a segunda, é chamada de **“tag”**. No caso da imagem **“ubuntu:14.04”**, **ubuntu** é o repositório e **14.04** é a tag.

Para o docker, o **“repositório”** é uma abstração do conjunto de imagens. Não confunda com o local de armazenamento das imagens, que detalharemos mais adiante. Já a **“tag”**, é uma abstração para criar unidade dentro do conjunto de imagens definidas no **“repositório”**.

Um **“repositório”** pode conter mais de uma **“tag”** e cada conjunto repositório:tag representa uma imagem diferente.

Execute [o comando](https://docs.docker.com/engine/reference/commandline/images/) abaixo para visualizar todas as imagens que se encontram localmente na sua estação, nesse momento:

```
docker image list
```

### Como criar imagens

Há duas formas de criar imagens customizadas: com **commit** e com **Dockerfile**.

#### Criando imagens com commit

É possível criar imagens executando o comando [commit](https://docs.docker.com/engine/reference/commandline/commit/), relacionado a um contêiner. Esse comando usa o status atual do contêiner escolhido e cria a imagem com base nele.

Vamos ao exemplo. Primeiro criamos um contêiner qualquer:

```
docker container run -it --name containercriado ubuntu:16.04 bash
```

Agora que estamos no bash do contêiner, instalamos o nginx:

```
apt-get update
apt-get install nginx -y
exit
```

Paramos o contêiner com o comando abaixo:

```
docker container stop containercriado
```

Agora, efetuamos o **commit** desse **contêiner** em uma **imagem**:

```
docker container commit containercriado meuubuntu:nginx
```

No exemplo do comando acima, **containercriado** é o nome do contêiner criado e modificado nos passos anteriores; o nome **meuubuntu:nginx** é a imagem resultante do **commit**; o estado do **containercriado** é armazenado em uma imagem chamada **meuubuntu:nginx** que, nesse caso, a única modificação que temos da imagem oficial do ubuntu na versão 16.04 é o pacote **nginx** instalado.

Para visualizar a lista de imagens e encontrar a que acabou de criar, execute novamente o comando abaixo:

```
docker image list
```

Para testar sua nova imagem, vamos criar um contêiner a partir dela e verificar se o nginx está instalado:

```
docker container run -it --rm meuubuntu:nginx dpkg -l nginx
```

Se quiser validar, pode executar o mesmo comando na imagem oficial do ubuntu:

```
docker container run -it --rm ubuntu:16.04 dpkg -l nginx
```

> Vale salientar que o método **commit** não é a melhor opção para criar imagens, pois, como verificamos, o processo de modificação da imagem é completamente manual e apresenta certa dificuldade para rastrear as mudanças efetuadas, uma vez que, o que foi modificado manualmente não é registrado, automaticamente, na estrutura do docker.

#### Criando imagens com Dockerfile

Quando se utiliza Dockerfile para gerar uma imagem, basicamente, é apresentada uma lista de instruções que serão aplicadas em determinada imagem para que outra imagem seja gerada com base nas modificações.

![Dockerfile](images/dockerfile.png)

Podemos resumir que o arquivo Dockerfile, na verdade, representa a exata diferença entre uma determinada imagem, que aqui chamamos de **base**, e a imagem que se deseja criar. Nesse modelo temos total rastreabilidade sobre o que será modificado na nova imagem.

Voltemos ao exemplo da instalação do nginx no ubuntu 16.04.

Primeiro crie um arquivo qualquer para um teste futuro:

```
touch arquivo_teste
```

Crie um arquivo chamado **Dockerfile** e dentro dele o seguinte conteúdo:

```
FROM ubuntu:16.04
RUN apt-get update && apt-get install nginx -y
COPY arquivo_teste /tmp/arquivo_teste
CMD bash
```

No arquivo acima, utilizamos quatro [instruções](https://docs.docker.com/engine/reference/builder/):

**FROM** para informar qual imagem usaremos como base, nesse caso foi **ubuntu:16.04**.

**RUN** para informar quais comandos serão executados nesse ambiente para efetuar as mudanças necessárias na infraestrutura do sistema. São como comandos executados no shell do ambiente, igual ao modelo por commit, mas nesse caso foi efetuado automaticamente e, é completamente rastreável, já que esse Dockerfile será armazenado no sistema de controle de versão.

**COPY** é usado para copiar arquivos da estação onde está executando a construção para dentro da imagem. Usamos um arquivo de teste apenas para exemplificar essa possibilidade, mas essa instrução é muito utilizada para enviar arquivos de configuração de ambiente e códigos para serem executados em serviços de aplicação.

**CMD** para informar qual comando será executado por padrão, caso nenhum seja informado na inicialização de um contêiner a partir dessa imagem. No exemplo, colocamos o comando bash, se essa imagem for usada para iniciar um contêiner e não informamos o comando, ele executará o bash.

Após construir seu Dockerfile basta executar o [comando](https://docs.docker.com/engine/reference/commandline/build/) abaixo:

```
docker image build -t meuubuntu:nginx_auto .
```

Tal comando tem a opção **“-t”**, serve para informar o nome da imagem a ser criada. No caso, será **meuubuntu:nginx_auto** e o **“.”** ao final, informa qual contexto deve ser usado nessa construção de imagem. Todos os arquivos da pasta atual serão enviados para o serviço do docker e apenas eles podem ser usados para manipulações do Dockerfile (exemplo do uso do COPY).

#### A ordem importa

É importante atentar que o arquivo **Dockerfile** é uma sequência de instruções lidas do topo à base e cada linha é executada por vez. Se alguma instrução depender de outra instrução, essa dependência deve ser descrita mais acima no documento.

O resultado de  cada instrução do arquivo é armazenado em cache local. Caso o **Dockerfile** não seja modificado na próxima criação da imagem (**build**), o processo não demorará, pois tudo estará no cache. Se houver alterações, apenas a instrução modificada e as posteriores serão executadas novamente.

A sugestão para melhor aproveitar o cache do **Dockerfile** é sempre manter as instruções frequentemente alteradas mais próximas da base do documento. Vale lembrar de atender também as dependências entre instruções.

Um exemplo para deixar mais claro:

```
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install nginx
RUN apt-get install php5
COPY arquivo_teste /tmp/arquivo_teste
CMD bash
```

Caso modifiquemos a terceira linha do arquivo e, ao invés de instalar o nginx, mudarmos para apache2, a instrução que faz o update no apt não será executada novamente, e sim a instalação do apache2, pois acabou de entrar no arquivo, assim como o php5 e a cópia do arquivo, pois todos eles são subsequentes a linha modificada.

Como podemos perceber, de posse do arquivo **Dockerfile**, é possível ter a exata noção de quais mudanças foram efetuadas na imagem e, assim, registrar as modificações no sistema de controle de versão.
