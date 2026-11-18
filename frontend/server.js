const express = require("express");
const path = require("path");

const app = express();
<<<<<<< HEAD

const PORT = process.env.PORT || 3000;
const FLASK_URL =
    process.env.FLASK_URL || "http://127.0.0.1:5000";
=======
const PORT = Number(process.env.PORT || 3000);
const FLASK_URL = process.env.FLASK_URL || "http://127.0.0.1:5000";
>>>>>>> f08f857 (terraform changes)

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

app.post("/submit", async (req, res) => {
    try {
        const response = await fetch(`${FLASK_URL}/api/submit`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(req.body)
        });

        const result = await response.json();

        if (!response.ok || !result.success) {
            return res.status(response.status || 500).json({
                success: false,
                error: result.error || "Failed to submit data"
            });
        }

        return res.json({
            success: true,
            message: "Data submitted successfully"
        });
    } catch (error) {
        console.error("Flask backend error:", error.message);
<<<<<<< HEAD

=======
>>>>>>> f08f857 (terraform changes)
        return res.status(502).json({
            success: false,
            error: "Unable to connect to Flask backend"
        });
    }
});

app.get("/success", (req, res) => {
    res.sendFile(path.join(__dirname, "public", "success.html"));
});

app.listen(PORT, "0.0.0.0", () => {
<<<<<<< HEAD
    console.log(`Node.js server running on port ${PORT}`);
=======
    console.log(`Node.js server listening on port ${PORT}`);
>>>>>>> f08f857 (terraform changes)
    console.log(`Flask backend: ${FLASK_URL}`);
});
