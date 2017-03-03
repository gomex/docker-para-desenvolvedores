# Configurações

Seguindo a lista do modelo [12factor](http://12factor.net/), temos **“Configurações”** como terceira boa prática.

Quando estamos criando um software aplicamos um determinado comportamento dentro do código e normalmente ele não é parametrizável, ou seja, para que essa aplicação se comporte de uma forma diferente será necessário mudar uma parte do código.

A necessidade de modificar o código para trocar o comportamento da aplicação inviabiliza que a mesma seja executa em sua máquina (desenvolvimento) da mesma forma que será usada para atender os usuários (produção) e com isso acabamos com toda possibilidade de portabilidade, e sem isso qual seria a vantagem de se usar contêineres, certo?

O objetivo dessa boa prática é viabilizar a configuração da aplicação sem a necessidade de modificar o código da mesma.

Como o comportamento da aplicação varia de acordo com o ambiente onde ela está executando, sendo assim, as configurações devem ser feitas baseadas nisso.

Seguem abaixo alguns exemplo:

 - Configuração de banco de dados que normalmente são diferentes entre os ambientes
 - Credenciais para acesso a serviços remotos (Ex. Digital Ocean ou Twitter)
 - Qual nome de DNS será usado pela aplicação

Como já falamos anteriormente, quando a configuração está estaticamente explícita no código, será necessário modificar manualmente e efetuar um novo build dos binários a cada reconfiguração do sistema.

Como demonstramos na boa prática codebase, usamos uma variável de ambiente para modificar qual o volume que usaremos no redis, ou seja, de certa forma já estamos seguindo essa boa prática, mas iremos um pouco além e mudaremos não somente o comportamento da infraestrutura, mas sim algo inerente ao código em si.

Segue abaixo a aplicação modificada:

```
from flask import Flask
from redis import Redis
import os
host_run=os.environ.get('HOST_RUN', '0.0.0.0')
debug=os.environ.get('DEBUG', 'True')
app = Flask(__name__)
redis = Redis(host='redis', port=6379)
@app.route('/')
def hello():
   redis.incr('hits')
   return 'Hello World! %s times.' % redis.get('hits')
if __name__ == "__main__":
   app.run(host=host_run, debug=debug)
``` 

Lembrando! Para acessar o código dessa prática basta clonar [esse repositório](https://github.com/gomex/exemplo-12factor-docker) e acessar a pasta **“factor3“**.

Como podemos perceber, adicionamos alguns parâmetros na configuração do endereço usado para iniciar a aplicação web, que será parametrizado com base no valor da variável de ambiente **“HOST_RUN”** e a possibilidade de efetuar ou não o debug dessa aplicação com a variável de ambiente **“DEBUG“**.

Vale salientar que nesse caso a variável de ambiente precisa ser passada para o contêiner, ou seja, não basta ter essa variável no docker host. Ela precisa ser enviada para o contêiner usando o parâmetro “-e” caso utilize o comando “docker run” ou a instrução “environment” no docker-compose.yml:

```
version: "2"
services:
  web:
    build: .
    ports:
     - "5000:5000"
    volumes:
     - .:/code
    labels:
     - 'app.environment=${ENV_APP}'
    environment:
     - HOST_RUN=${HOST_RUN}
     - DEBUG=${DEBUG}
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

Para executar o docker-compose, deveríamos fazer da seguinte maneira:

```
export HOST_RUN="0.0.0.0"; export DEBUG=True ; docker-compose up -d
```

Como podem perceber no comando acima ele usará as variáveis de ambiente **“HOST_RUN”** e **“DEBUG”** do docker host para enviar para as variáveis de ambiente com os mesmos nomes dentro do contêiner, que por sua vez será consumido pelo código python. Em caso de não haver parâmetros ele assume os valores padrões estipulados no código.

Essa boa prática é seguida com ajuda do Docker, pois o código é o mesmo e a configuração é um anexo da solução, que pode ser parametrizada de maneira distinta com base no que for configurado nas variáveis de ambiente.

Se aplicação crescer bastante, as variáveis podem ser carregadas em arquivo e parametrizadas no docker-compose.yml com a opção “env_file”.

