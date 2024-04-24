import discord
import os
import requests 
import json
import random
from dotenv import load_dotenv
from responses import get_response

load_dotenv()

TOKEN = os.getenv('TOKEN')

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)


async def send_message(message:str,user_message:str) -> None:
    if not user_message:
        return 
    if is_private := user_message[0] == '?':
        user_message = user_message[1:]
    
    try:
        response: str = get_response(user_message)
        await message.author.send(response) if is_private else message.channel.send(response)
    except Exception as error:
        print(error)

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')

@client.event 
async def on_message(message):
    msg = message.content
    if message.author == client.user:
        return
    if msg.startswith('$getQuote'):
        quote = get_quote()
        await message.channel.send(quote)
    if any(word in msg for word in sad_words):
        await message.channel.send(random.choice(starter_encourgements))
    if msg.startswith('$rolldice'): 
        diceRoll = random.randint(1,6)
        await message.channel.send(diceRoll)
    
    


client.run(TOKEN)