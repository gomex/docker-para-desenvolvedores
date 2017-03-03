# Descartabilidade

Seguindo a lista do modelo [12factor](http://12factor.net/pt_br), temos **“Descartabilidade”** como nona boa prática.

Quando falamos de aplicações web, espera-se que mais de um processo atenda a todo tráfego que é requisitado para esse serviço, porém tão importante quanto a habilidade de iniciar novos processos, é a capacidade de que um processo defeituoso termine na mesma velocidade que iniciou, pois um processo que demora para finalizar pode comprometer toda solução, uma vez que ela pode ainda estar atendemos requisições de forma defeituosa.

![](images/descartabilidade1.png)

Em resumo podemos dizer que aplicações web deveriam ser capazes de remover rapidamente processos defeituosos.


Com objetivo de evitar que o serviço prestado esteja muito dependente das instâncias que o servem, esta boa prática indica que as aplicações devem ser descartáveis, ou seja, que o fato de desligar uma de suas instâncias não afete a solução como um todo.

No Docker tem a opção de descartar automaticamente um contêiner após seu uso, no **docker run** utilize a opção **–rm**. Vale salientar que essa opção não funciona em modo **daemon (-d)**, ou seja, só fará sentido utilizar essa opção em modo **interativo (-i)**.

Outro detalhe importante nessa boa prática é viabilizar que seu código esteja preparado para se desligar “graciosamente” e reiniciar sem erros. Dessa forma, ao escutar um **SIGTERM** seu código deveria terminar qualquer requisição em andamento e então desligar o processo sem problemas e de forma rápida, permitindo também que seja rapidamente atendido por outro processo.

Entendemos como desligamento “gracioso” quando uma aplicação é capaz de auto finalizar sem causar danos a solução, ou seja, ao receber um sinal para desligar ela imediatamente deve recusar novas requisições e apenas finalizar as tarefas pendentes em execução no momento. O que está implícito nesse modelo é que as requisições HTTP sejam curtas (não mais que alguns poucos segundos) e nos casos de conexões mais longas que o cliente possa se reconectar automaticamente caso a conexão seja perdida.

Nossa aplicação teve a seguinte mudança para atender a especificação:

```
from flask import Flask
from redis import Redis
from multiprocessing import Process
import signal, os

host_redis=os.environ.get('HOST_REDIS', 'redis')
port_redis=os.environ.get('PORT_REDIS', '6379')

app = Flask(__name__)
redis = Redis(host=host_redis, port=port_redis)

@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello World! %s times.' % redis.get('hits')

if __name__ == "__main__":
    def server_handler(signum, frame):
        print 'Signal handler called with signal', signum
        server.terminate()
        server.join()
    
    signal.signal(signal.SIGTERM, server_handler)

    def run_server():
        app.run(host="0.0.0.0", debug=True)

    server = Process(target=run_server)
    server.start()
```

Como podem ver no código acima, adicionei um tratamento para quando receber um sinal de SIGTERM ele finalizar rapidamente o processo. Sem esse tratamento o código demoraria um pouco mais para ser desligado. Dessa forma podemos concluir que nossa solução já é descartável o suficiente, ou seja, podemos desligar e reiniciar os containers em outro docker host, e essa mudança não causará impacto na integridade dos dados.

Para fins de entendimento do que estamos trabalhando aqui, cabe falar um pouco sobre isso. De acordo com o Wikipedia, sinal é: “…uma notificação assíncrona enviada a processos com o objetivo de notificar a ocorrência de um evento.” E o SIGTERM é “…o nome de um sinal conhecido por um processo informático em sistemas operativos POSIX. Este é o sinal padrão enviado pelos comandos kill e killall. Ele causa o término do processo, como em SIGKILL, porém pode ser interpretado ou ignorado pelo processo. Com isso, SIGTERM realiza um encerramento mais amigável, permitindo a liberação de memória e o fechamento dos arquivos.”

Para realizar o teste de tudo que apresentado até então, realize o clone do repositório ([https://github.com/gomex/exemplo-12factor-docker](https://github.com/gomex/exemplo-12factor-docker)) e acesse a pasta factor8 (isso mesmo, a número 8, vamos demonstrar aqui a diferença pra o factor9), executando o comando abaixo para iniciar os contêineres:

```
docker-compose up -d
```

Depois execute o comando abaixo para finalizar os contêineres:

```
time docker-compose stop
```

Você verá que a finalização do worker demorará cerca de 11 segundos, isso porque o comportamento do docker-compose para finalizar é primeiro tentar um **SIGTERM** e esperar por 10 segundos que a aplicação finalize sozinha, caso contrário é enviado um **SIGKILL** que finaliza o processo mais bruscamente. Esse timeout é configurável. Caso deseje modificar basta usar o parâmetro **“-t”** ou **“–timeout“**. Vejam um exemplo:

```
docker-compose stop -t 5
```

Obs: O valor informado após o parâmetro deve ser considerado em segundos.

Agora para testar com o código modificado, basta mudar para a pasta **factor9** e executar o seguinte comando:

```
docker-compose up -d
```

Depois solicitar seu término:

```
time docker-compose stop
```

Veja que o processo worker foi finalizar bem mais rápido, pois recebeu o sinal SIGTERM e a aplicação fez seu serviço de auto finalização e não precisou receber um sinal SIGKILL para ser de fato finalizado.