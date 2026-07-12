const request = require("supertest");
const app = require("./server");

describe("Dream11 Mega App", () => {
  test("GET /health returns 200 and OK", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.text).toBe("OK");
  });

  test("GET /ready returns 200 and READY", async () => {
    const res = await request(app).get("/ready");
    expect(res.status).toBe(200);
    expect(res.text).toBe("READY");
  });

  test("GET /api/status returns app info as JSON", async () => {
    const res = await request(app).get("/api/status");
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("message");
    expect(res.body).toHaveProperty("version");
  });

  test("x-powered-by header is disabled", async () => {
    const res = await request(app).get("/health");
    expect(res.headers["x-powered-by"]).toBeUndefined();
  });
});
