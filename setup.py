from setuptools import setup, find_packages

setup(
    name="streamlink_mod",
    version="0.1",
    packages=find_packages(),
    install_requires=["psutil", "streamlink"],
    entry_points={
        "console_scripts": [
            "streamlink_mod=streamlink_mod.streamlink_mod:main",
        ],
    },
)
