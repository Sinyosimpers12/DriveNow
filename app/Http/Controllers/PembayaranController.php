<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class PembayaranController extends Controller
{
    public function edit()
    {
        return view('pembayaran.edit');
    }

    public function update(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'bank' => 'required|string|max:255',
            'account_number' => 'required|string|max:20',
        ]);

        $data = [
            'name' => $request->input('name'),
            'bank' => $request->input('bank'),
            'account_number' => $request->input('account_number'),
        ];

        $response = Http::post('https://pa-test-da05d-default-rtdb.asia-southeast1.firebasedatabase.app/pembayaran.json', $data);

        if ($response->successful()) {
            return redirect()->back()->with('success', 'Data Berhasil Diperbarui.');
        } else {
            return redirect()->back()->withErrors(['api' => 'Failed to submit data to the API.']);
        }
    }
}
