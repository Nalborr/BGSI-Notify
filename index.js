const { Client, EmbedBuilder, GatewayIntentBits } = require('discord.js');
const express = require('express');
const bodyParser = require('body-parser');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages
    ]
});

const CHEST_CHANNEL_ID = 'process.env.CHEST_CHANNEL_ID'; // ID канала для сундуков
const EGG_CHANNEL_ID = 'process.env.EGG_CHANNEL_ID';     // ID канала для яиц

const messageCache = new Map();

const app = express();
app.use(bodyParser.json());

app.post('/api/roblox', async (req, res) => {
    try {
        console.log('Получен запрос:', JSON.stringify(req.body, null, 2));
        const { type, name, timer, luck } = req.body;

        if (type === 'chest') {
            const channel = client.channels.cache.get(CHEST_CHANNEL_ID);
            if (!channel) {
                console.error('Канал не найден:', CHEST_CHANNEL_ID);
                return res.status(500).send('Channel not found');
            }
            const embed = new EmbedBuilder()
                .setTitle('🧰 Новый сундук появился!')
                .setColor(0xFFD700)
                .addFields(
                    { name: 'Тип сундука', value: name, inline: true },
                    { name: 'Время', value: timer, inline: true }
                )
                .setTimestamp();

            const cacheKey = `${name}-chest`;
            if (messageCache.has(cacheKey)) {
                const msg = await channel.messages.fetch(messageCache.get(cacheKey));
                await msg.edit({ embeds: [embed] });
                console.log(`Обновлено: ${name}`);
            } else {
                const msg = await channel.send({ embeds: [embed] });
                messageCache.set(cacheKey, msg.id);
                console.log(`Отправлено: ${name}`);
            }
        } else if (type === 'egg') {
            const channel = client.channels.cache.get(EGG_CHANNEL_ID);
            if (!channel) {
                console.error('Канал не найден:', EGG_CHANNEL_ID);
                return res.status(500).send('Channel not found');
            }
            const embed = new EmbedBuilder()
                .setTitle('🥚 Новое яйцо появилось!')
                .setColor(0x00FF00)
                .addFields(
                    { name: 'Тип яйца', value: name, inline: true },
                    { name: 'Время', value: timer, inline: true },
                    { name: 'Удача', value: luck, inline: true }
                )
                .setTimestamp();

            const cacheKey = `${name}-egg`;
            if (messageCache.has(cacheKey)) {
                const msg = await channel.messages.fetch(messageCache.get(cacheKey));
                await msg.edit({ embeds: [embed] });
                console.log(`Обновлено: ${name}`);
            } else {
                const msg = await channel.send({ embeds: [embed] });
                messageCache.set(cacheKey, msg.id);
                console.log(`Отправлено: ${name}`);
            }
        } else {
            console.warn('Неизвестный тип:', type);
            return res.status(400).send('Invalid type');
        }

        res.status(200).send('Success');
    } catch (error) {
        console.error('Ошибка:', error);
        res.status(500).send('Error');
    }
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

client.once('ready', () => {
    console.log(`Bot is ready as ${client.user.tag}`);
});

client.login(process.env.DISCORD_TOKEN);
