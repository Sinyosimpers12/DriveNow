<section>
    <header>
        <h2 class="text-lg font-medium text-gray-900">
            {{ __('Informasi pembayaran ') }}
        </h2>
        <p class="mt-1 text-sm text-gray-600">
            {{ __("Silakan Masukan Informasi Bank Anda.") }}
        </p>
    </header>

    <form method="post" action="{{ route('pembayaran.update') }}" class="mt-6 space-y-6">
        @csrf
        @method('patch')

        <div>
            <x-input-label for="name" :value="__('Name')" />
            <x-text-input id="name" name="name" type="text" class="mt-1 block w-full" :value="old('name', $user->name ?? '')" required autofocus autocomplete="name" />
            <x-input-error class="mt-2" :messages="$errors->get('name')" />
        </div>

        <div>
            <x-input-label for="bank" :value="__('Bank')" />
            <x-text-input id="bank" name="bank" type="text" class="mt-1 block w-full" :value="old('bank', $user->bank ?? '')" required autocomplete="bank" />
            <x-input-error class="mt-2" :messages="$errors->get('bank')" />
        </div>

        <div>
            <x-input-label for="account_number" :value="__('Account Number')" />
            <x-text-input id="account_number" name="account_number" type="text" class="mt-1 block w-full" :value="old('account_number', $user->account_number ?? '')" required autocomplete="account_number" />
            <x-input-error class="mt-2" :messages="$errors->get('account_number')" />
        </div>

        <div class="flex items-center gap-4">
            <x-primary-button>{{ __('Save') }}</x-primary-button>
        </div>
    </form>
</section>
