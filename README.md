# AI-Virtual-Assistant
AI assistant powered by Rasa<br>
<img src="https://d33wubrfki0l68.cloudfront.net/37c130df420c6a673ad6c2e494c0224606ace77b/e6afa/static/60e441f8eadef13bea0cc790c8cf188b/rasa-logo.svg" height=100px/>

# What can i do
##### Run on Console
* Clone the repo
* In terminal run command ```rasa shell``` to chat with the bot on console

##### Run on a Web Browser
* Clone the repo
* In terminal navigate inside ```summerproject``` folder and run command ```python manage.py runserver```, this is start a Django server on your machine.
* After that, navigate to ```rasa``` folder and run command, ```rasa run -m models --enable-api --cors "*" --debug```, this is start a rasa server.
* Final step, again navigate to ```rasa``` folder and run command, ```rasa run actions```, this is start a rasa custom actions server.
<details>
  <summary><b>IMPORTANT NOTE</b></summary>
  <p>make sure you train the model after cloning the repo or after making any changes to the code.</p>
  <p>To train the model, navigate to <b>rasa</b> folder and run command <b>rasa train</b></p>
  
</details>
