cd src

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
else
    echo "Virtual environment already exists."
fi

source venv/bin/activate

pip install -r requeriments.txt

rm venv/bin/bin2tap.py

pip uninstall -y opencv-python
pip install opencv-python-headless
