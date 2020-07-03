# Descartabilidade

Na nona posição da lista do modelo [12factor](https://12factor.net/pt_br/), a **“Descartabilidade”**.

Quando falamos de aplicações web, espera-se que mais de um processo atenda a todo tráfego requisitado para o serviço. Porém, tão importante quanto a habilidade de iniciar novos processos, a capacidade de um processo defeituoso terminar na mesma velocidade que iniciou, pois um processo que demora para finalizar pode comprometer toda solução, uma vez que ela pode ainda estar atendemos requisições de forma defeituosa.

![](images/descartabilidade1.png)

Em resumo, podemos dizer que aplicações web deveriam ser capazes de remover rapidamente processos defeituosos.

Com objetivo de evitar que o serviço prestado seja dependente das instâncias que o servem, a boa prática indica que as aplicações devem ser descartáveis, ou seja, desligar uma de suas instâncias não deve afetar a solução como um todo.

O Docker tem a opção de descartar automaticamente um contêiner após o uso - no **docker container run** utilize a opção **–rm**. Vale salientar que essa opção não funciona em modo **daemon (-d)**, portanto, só faz sentido utilizar no modo **interativo (-i)**.

Outro detalhe importante na boa prática é viabilizar que o código desligue “graciosamente” e reinicie sem erros. Assim, ao escutar um **SIGTERM**, o código deve terminar qualquer requisição em andamento e então desligar o processo sem problemas e de forma rápida, permitindo, também, que seja rapidamente atendido por outro processo.

Entendemos como desligamento “gracioso” uma aplicação capaz de auto finalizar sem danos à solução; ao receber sinal para desligar, imediatamente recusa novas requisições e apenas finaliza as tarefas pendentes em execução naquele momento. Implícito nesse modelo: as requisições HTTP são curtas (não mais que poucos segundos) e, nos casos de conexões longas, o cliente pode se reconectar automaticamente caso a conexão seja perdida.

A aplicação sofreu a seguinte mudança para atender a especificação:

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

No código acima, adicionamos tratamento para quando receber um sinal de SIGTERM, finalizar rapidamente o processo. Sem o tratamento, o código demora mais para ser desligado. Dessa forma, concluímos que a solução é descartável o suficiente. Podemos desligar e reiniciar os contêineres em outro Docker Host e a mudança não causará impacto na integridade dos dados.

Para fins de entendimento sobre o que trabalhamos aqui, cabe esclarecimento, de acordo com o Wikipedia, sinal é: “(...) notificação assíncrona enviada a processos com o objetivo de notificar a ocorrência de um evento.” E, o SIGTERM: “(...) nome de um sinal conhecido por um processo informático em sistemas operativos POSIX. Este é o sinal padrão enviado pelos comandos kill e killall. Ele causa o término do processo, como em SIGKILL, porém pode ser interpretado ou ignorado pelo processo. Com isso, SIGTERM realiza um encerramento mais amigável, permitindo a liberação de memória e o fechamento dos arquivos.”

Para realizar o teste do que foi apresentado até então, realize o clone do repositório ([https://github.com/gomex/exemplo-12factor-docker](https://github.com/gomex/exemplo-12factor-docker)) e acesse a pasta factor8 (isso mesmo, a número 8, vamos demonstrar a diferença pra o factor9), executando o comando abaixo para iniciar os contêineres:

```
docker-compose up -d
```

Depois, execute o comando abaixo para finalizar os contêineres:

```
time docker-compose stop
```

Você verá que a finalização do worker demora cerca de 11 segundos, isso porque o comportamento do Docker-Compose, para finalizar, primeiro faz um **SIGTERM** e espera por 10 segundos que a aplicação finalize sozinha, caso contrário, envia um **SIGKILL** que finaliza o processo bruscamente. Esse timeout é configurável. Caso deseje modificar, basta usar o parâmetro **“-t”** ou **“–timeout“**. Veja um exemplo:

```
docker-compose stop -t 5
```

Obs: O valor informado, após o parâmetro, é considerado em segundos.

Agora, para testar o código modificado, mude para a pasta **factor9** e execute o seguinte comando:

```
docker-compose up -d
```

Depois, solicite o término:

```
time docker-compose stop
```

Veja que o processo worker finalizou mais rápido, pois recebeu o sinal SIGTERM. A aplicação fez o serviço de auto finalização e não precisou receber um sinal SIGKILL para ser, de fato, finalizado.
