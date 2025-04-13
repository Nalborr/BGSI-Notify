const express = require('express');
const axios = require('axios');

const app = express();

app.get('/proxy', async (req, res) => {
    try {
        const data = req.query;
        console.log('Получены данные от Roblox:', data);
        await axios.post('https://bgsi-notify.onrender.com/api/roblox', data);
        res.send('Success');
    } catch (error) {
        console.error('Ошибка прокси:', error.message);
        res.status(500).send('Error');
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Proxy running on port ${PORT}`));
