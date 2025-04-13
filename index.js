const { Client, EmbedBuilder, GatewayIntentBits } = require('discord.js');
const express = require('express');
const bodyParser = require('body-parser');

// Настройки бота
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages
    ]
});

// ID каналов Discord (замените на ваши)
const CHEST_CHANNEL_ID = 'process.env.CHEST_CHANNEL_ID'; // ID канала для сундуков
const EGG_CHANNEL_ID = 'process.env.EGG_CHANNEL_ID';     // ID канала для яиц

// Хранилище для message_id (чтобы редактировать сообщения)
const messageCache = new Map();

// Создание Express-приложения
const app = express();
app.use(bodyParser.json());

// Обработчик HTTP-запросов
app.post('/api/roblox', async (req, res) => {
    try {
        const { type, name, timer, luck } = req.body;

        if (type === 'chest') {
            const channel = client.channels.cache.get(CHEST_CHANNEL_ID);
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
                // Редактируем существующее сообщение
                const msg = await channel.messages.fetch(messageCache.get(cacheKey));
                await msg.edit({ embeds: [embed] });
            } else {
                // Отправляем новое сообщение
                const msg = await channel.send({ embeds: [embed] });
                messageCache.set(cacheKey, msg.id);
            }
        } else if (type === 'egg') {
            const channel = client.channels.cache.get(EGG_CHANNEL_ID);
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
                // Редактируем существующее сообщение
                const msg = await channel.messages.fetch(messageCache.get(cacheKey));
                await msg.edit({ embeds: [embed] });
            } else {
                // Отправляем новое сообщение
                const msg = await channel.send({ embeds: [embed] });
                messageCache.set(cacheKey, msg.id);
            }
        }

        res.status(200).send('Success');
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Error');
    }
});

// Запуск сервера
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

// Событие готовности бота
client.once('ready', () => {
    console.log(`Bot is ready as ${client.user.tag}`);
});

// Запуск бота
client.login(process.env.DISCORD_TOKEN);
