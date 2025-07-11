import React, { useState } from "react";
import axios from "axios";
import "./App.css";

export default function App() {
    const [response, setResponse] = useState("");

    const sendData = async () => {
        try {
            const res = await axios.post("/api/ping", {
                random: Math.random().toString(36).substring(7),
            });
            setResponse(JSON.stringify(res.data));
        } catch (err) {
            setResponse("Error: " + err.message);
        }
    };

    return (
        <div className="container">
            <h1>🚀 Our Tool is Coming Soon</h1>
            <p>We’re cooking something awesome! Stay tuned.</p>
            <button onClick={sendData}>Send Random Data</button>
            <pre>{response}</pre>
        </div>
    );
}
