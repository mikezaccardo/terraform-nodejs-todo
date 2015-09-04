provider "aws" {
    access_key = "ACCESS_KEY_HERE"
    secret_key = "SECRET_KEY_HERE"
    region = "us-east-1"
}

resource "aws_instance" "redis" {
    ami = "ami-408c7f28"
    instance_type = "t1.micro"
    key_name = "KEY_PAIR_NAME_HERE"
    tags {
        Name = "nodejs-todo-redis"
    }
    
    connection {
        user = "ubuntu"
        key_file = "PATH_TO_PRIVATE_KEY_HERE"
      }

    provisioner "remote-exec" {
        inline = [
            "sleep 10",
            "sudo apt-get update -y",
            "sudo apt-get install -y redis-server",
            "sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf",
            "sudo service redis-server restart",
            "sudo service redis-server status"
        ]
    }
}

resource "aws_instance" "server" {
    ami = "ami-408c7f28"
    instance_type = "t1.micro"
    key_name = "KEY_PAIR_NAME_HERE"
    tags {
        Name = "nodejs-todo-server"
    }
    
    connection {
        user = "ubuntu"
        key_file = "PATH_TO_PRIVATE_KEY_HERE"
      }

    provisioner "remote-exec" {
        inline = [
            "sleep 10",
            "sudo apt-get update -y",
            "sudo apt-get install -y nodejs npm git-core",
            "git clone https://github.com/grkvlt/nodejs-todo/",
            "cd nodejs-todo",
            "sudo npm install -g express ejs jasmine-node underscore method-override cookie-parser express-session body-parser cookie-session redis redis-url connect",
            "export NODE_PATH=\"$NODE_PATH:$(npm root -g)\"",
            "echo $NODE_PATH",
            "export REDISTOGO_URL=\"redis://${aws_instance.redis.public_ip}:6379\"",
            "echo $REDISTOGO_URL",
            "nohup nodejs server.js > console.out 2>&1 &",
            "sleep 10",
            "ps aux | grep server.js"
        ]
    }
}
