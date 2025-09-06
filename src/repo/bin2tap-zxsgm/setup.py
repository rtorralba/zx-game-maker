from setuptools import setup, find_packages
import pathlib

HERE = pathlib.Path(__file__).parent
README = (HERE / "README.md").read_text()

setup(
    name='bin2tap_zxsgm',
    version='0.3',
    author='Raül Torralba',
    description='Convert a binary file into ZX Spectrum TAP file',
    long_description=README,
    long_description_content_type='text/markdown',
    packages=find_packages(),
    include_package_data=True,
    entry_points='''
        [console_scripts]
        bin2tap_zxsgm=bin2tap_zxsgm.cli:main
    ''',
    url = 'https://github.com/rtorralba/bin2tap',
)