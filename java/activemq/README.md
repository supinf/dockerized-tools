# Apache ActiveMQ

http://activemq.apache.org/

[![supinf/activemq](http://dockeri.co/image/supinf/activemq)](https://hub.docker.com/r/supinf/activemq)

## Supported tags and respective `Dockerfile` links

・latest ([java/activemq/versions/5.15/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/java/activemq/versions/5.15/Dockerfile))  
・5.15 ([java/activemq/versions/5.15/Dockerfile](https://github.com/supinf/dockerized-tools/blob/master/java/activemq/versions/5.15/Dockerfile))  

## Port mappings

| Port | Protocol | memo |
|:-:|:-|:-|
| 61616 | JMS | |
| 5672 | AMQP | |
| 61613 | STOMP | |
| 1883 | MQTT | |
| 61614 | WebSocket | |
| 8161 | UI | http://localhost:8161/admin (admin/admin) |

## Usage

```
$ docker run --rm -p 1883:1883 -p 8161:8161 supinf/activemq:5.15
```
