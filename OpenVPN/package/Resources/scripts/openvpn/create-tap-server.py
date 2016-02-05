#!/usr/bin/python
from flask import Flask, jsonify
import subprocess

app = Flask(__name__)

@app.route('/api/v1/id_rsa')
def got():
    txt=open("/root/.ssh/id_rsa.pub")
    return txt.read()

@app.route('/api/v1/create/<string:external_ip>')
def create(external_ip):
   subprocess.check_output("bash /opt/openvpn/create-tap.sh " + external_ip, shell=True) 
   return 'OK' 

if __name__ == '__main__':
    app.run(debug=True, host = '0.0.0.0')

