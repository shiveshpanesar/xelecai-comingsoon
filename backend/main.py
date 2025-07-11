from fastapi import FastAPI, Request
from pydantic import BaseModel
from qdrant_client import QdrantClient
from qdrant_client.http.models import PointStruct
import uuid
import random
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can change to ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
client = QdrantClient(host="qdrant", port=6333)

COLLECTION_NAME = "test-collection"


# Create collection on startup
@app.on_event("startup")
def setup_collection():
    try:
        client.recreate_collection(
            collection_name=COLLECTION_NAME,
            vectors_config={"size": 4, "distance": "Cosine"},
        )
    except:
        pass


class Payload(BaseModel):
    random: str


@app.post("/api/ping")
async def ping(data: Payload):
    # Generate fake vector
    vector = [random.random() for _ in range(4)]
    point = PointStruct(
        id=str(uuid.uuid4()), vector=vector, payload={"data": data.random}
    )
    client.upsert(collection_name=COLLECTION_NAME, points=[point])

    return {"message": "Data saved", "vector": vector}
