import asyncio

async def hello(name, delay):
    await asyncio.sleep(delay)
    print(f"Hello, {name}!")

async def main():
    # Create multiple coroutines
    tasks = [
        hello("Alice", 2),
        hello("Bob", 1),
        hello("Charlie", 3)
    ]
    # Run them concurrently
    await asyncio.gather(*tasks)

# Run the main coroutine
asyncio.run(main())